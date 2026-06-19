library(eph)
library(tidyverse)
library(lubridate)

## Descarga datos
vars <- c("ANO4", "TRIMESTRE","CODUSU", "NRO_HOGAR", "COMPONENTE", ## identificadores
          "REGION", "AGLOMERADO", "PONDERA", # region
          "CH04", "CH06", "NIVEL_ED", # demográficas
          "ESTADO", "CAT_OCUP", # laborales
          "PP04C", "PP04C99", # informalidad tamaño 
          "PP07H", "PP07I", #informalidad registro
          "PP03C")



df <- get_microdata(year=2007:2025, period=1:4, 
                    type="individual",
                    vars = vars)
## Preprocesamiento
### Carga archivo raw
df <- read_rds('./data/raw_data_eph.rds')

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
           AGLOMERADO == "La Rioja" ~ "2. La Rioja", 
           AGLOMERADO != "La Rioja" & REGION == "Noroeste" ~ "1. NOA-Resto",
           TRUE ~ "3. Resto país"))

### Procesamiento indicadores
df %>%
  filter(ANO4 >= 2007) %>%
  group_by(fecha, REGION, AGLOMERADO, la_rioja_region) %>%
  summarise(desoc = sum(desocupado*PONDERA),
            pea = sum(pea*PONDERA),
  ) %>%
  mutate(tasa_desoc = desoc/pea*100)




### Salva archivo final
df %>% write_rds('./data/proc_data_eph.rds')

