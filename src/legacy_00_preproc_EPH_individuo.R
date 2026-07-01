library(eph)
library(tidyverse)
library(lubridate)

## Descarga datos
vars <- c("ANO4", "TRIMESTRE","CODUSU", "NRO_HOGAR", "COMPONENTE", ## identificadores
          "REGION", "AGLOMERADO", "PONDERA", # region
          "CH03", "CH04", "CH06", "NIVEL_ED", "CH10", "CH12", "CH13", "CH14", # demográficas
          "ESTADO", "CAT_OCUP", # laborales
          "PP04C", "PP04C99", # informalidad tamaño 
          "PP07H", "PP07I", #informalidad registro
          "PP03C")

periods <- expand_grid(year = 2007:2025, period = 1:4)
tictoc::tic()
for (i in 1:nrow(periods)){
  p <- periods$period[[i]]
  y <- periods$year[[i]]
  
  out <- paste0('./data/raw_data/eph/individuo/', y, "_", p, "_EPH_individuo.rds")
  
  if (!file.exists(out)){
    
    cat("El archivo no existe. Descargando ", out )
    df <- get_microdata(
      period = p,
      year = y,
      type = "individual",
      vars = vars
    ) 
    
    df %>% write_rds(out)
  } else {
    cat("El archivo existe...")
     next
    }
  }
tictoc::toc()

#df <- get_microdata(year=2007:2025, period=1:4, 
#                    type="individual",
#                    vars = vars)



# 1. Get a list of all CSV files with their full system paths
files <- list.files(path = "./data/raw_data/eph/individuo", 
                    pattern = "\\.rds$", 
                    full.names = TRUE)

### Carga archivo raw
df <- files %>% 
  map(read_rds) %>% 
  bind_rows()

## Preprocesamiento
### Agrega etiquetas
df <- df %>%
  organize_labels(type = "individual")

## Transforma variables clave
df <- df %>%
  mutate(
    REGION = as.character(REGION),
    AGLOMERADO = as.character(AGLOMERADO),
    ESTADO = as.character(ESTADO),
    NIVEL_ED = as.character(NIVEL_ED),
    PP04C = as.character(PP04C),
    PP04C99 = as.character(PP04C99),
    CAT_OCUP = as.character(CAT_OCUP),
    PP07H = as.character(PP07H),
    PP07I = as.character(PP07I),
    ANO4 = as.numeric(ANO4),
    TRIMESTRE = unclass(TRIMESTRE)) %>%
  mutate(fecha = paste0(ANO4, "-0", TRIMESTRE))

### Procesamiento tasas laborales
df <- df %>%
  mutate(ocupado = if_else(ESTADO == "Ocupado", 1, 0),
         desocupado = if_else(ESTADO == "Desocupado", 1, 0),
         pea = if_else(ESTADO %in% c("Ocupado", "Desocupado"),1, 0),
         no_pea = if_else(!(ESTADO %in% c("Ocupado", "Desocupado")), 1, 0),
         fecha = paste0(ANO4, "-Q", TRIMESTRE)
  )

### Procesamiento nivel educativo
df <- df %>%
  mutate(niv_educ_sup = if_else(
    NIVEL_ED %in% c("Superior universitaria incompleta", 
                    "Superior universitaria completa"), 1, 0)) %>%
  mutate(mayor_25 = if_else((CH06 > 25 & CH06 != 99), 1, 0)) %>%
  mutate(mayor_25_superior = if_else((mayor_25 == 1 & niv_educ_sup == 1),1,0))

### Procesamiento informalidad
#### Tamanio
df <- df %>%
  mutate(PP04C_rec = case_when(
    PP04C == "0" ~ "NC",
    PP04C == "Ns./Nr." ~ "NR",
    PP04C %in% c("1 persona", "2 personas", "3 personas",
                 "4 personas", "5 personas") ~ "Hasta 5 personas",
    PP04C %in% c("6 a 10 personas", "11 a 25 personas",  "26 a 40 personas") ~ "6 a 40 personas",
    TRUE ~ "Más de 40 personas"
  )) %>%
  mutate(tamanio_estab = case_when(
    PP04C_rec == "NC" & PP04C99 == "0" ~ "NC",
    PP04C_rec == "NR" & PP04C99== "hasta 5" ~ "Hasta 5 personas",
    PP04C_rec == "NR" & PP04C99 == "de 6 a 40" ~ "6 a 40 personas", 
    PP04C_rec =="NR" & PP04C99 =="mas de 40" ~ "Más de 40 personas",
    PP04C_rec == "NR" & PP04C99 =="Ns./Nr.." ~ "NR"
  ))

#### Aportes
df <- df %>%
  mutate(
    descuento = if_else(PP07H == "Si", 1, 0),
    aporta = if_else(PP07I == "Si", 1, 0),
    asalariado_ocupado = if_else(
      (CAT_OCUP == "Obrero o empleado" & ESTADO == "Ocupado"), 1, 0)
  ) %>%
  mutate(
    aportes_descuentos = if_else(
        (aporta == 1 | descuento == 1), 1, 0)
  )

## Generación de agregados greográficos
df <- df %>%
  mutate(la_rioja_aglo = if_else(AGLOMERADO == "La Rioja", "La Rioja", "Resto"),
         la_rioja_region = case_when(
           AGLOMERADO == "La Rioja" ~ "3. La Rioja", 
           AGLOMERADO != "La Rioja" & REGION == "Noroeste" ~ "2. NOA-Resto",
           TRUE ~ "1. Resto país"))

### Procesamiento indicadores
#### Tasa empleo
df %>%
  filter(ANO4 >= 2007) %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(ocupado = sum(ocupado*PONDERA),
            pob_tot = sum(PONDERA),
  ) %>%
  mutate(tasa_empleo = ocupado/pob_tot*100) %>%
  write_csv('./data/inputs_md/10_tasa_empleo.csv')


#### Tasa desocupación
df %>%
  filter(ANO4 >= 2007) %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(desoc = sum(desocupado*PONDERA),
            pea = sum(pea*PONDERA),
  ) %>%
  mutate(tasa_desoc = desoc/pea*100) %>%
  write_csv('./data/inputs_md/04_tasa_desoc.csv')

#### Tasa informalidad a
df %>%
  filter(ANO4 >= 2007) %>%
  filter(ESTADO == "Ocupado" & CAT_OCUP=="Obrero o empleado") %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(formales = sum(aportes_descuentos*PONDERA),
            asalariados = sum(asalariado_ocupado*PONDERA),
  ) %>%
  mutate(tasa_inf_aportes = 100 - (formales/asalariados*100)) %>%
  write_csv('./data/inputs_md/09a_tasa_informalidad_aportes.csv')

#### Tasa informalidad b PENDIENTE


#### % mayores de 25 años con NED universitario
df %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(mayor_25_superior = sum(mayor_25_superior*PONDERA),
            pob_tot = sum(PONDERA)) %>%
  mutate(porc_mayor_25_superior = mayor_25_superior/pob_tot * 100) %>%
  write_csv('./data/inputs_md/12_mayor_25_superior.csv')



### Salva archivo final
#df %>% write_rds('./data/proc_data_eph.rds')

