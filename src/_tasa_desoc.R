library(eph)
library(tidyverse)
library(lubridate)

### Descarga datos
vars <- c("ANO4", "TRIMESTRE","CODUSU", "NRO_HOGAR", "COMPONENTE", ## identificadores
          "REGION", "AGLOMERADO", "PONDERA", # region
          "CH04", "CH06", "NIVEL_ED", # demográficas
          "ESTADO", "CAT_OCUP", # laborales
          "PP04C", "PP04C99", # informalidad tamaño 
          "PP07H", "PP07I", #informalidad registro
          "PP03C")

df <- get_microdata(year=2003:2025, period=1:4, 
                    type="individual",
                    vars = vars)

### Guarda archivo raw
df %>% write_rds('./data/raw_data_eph.rds')


### Carga archivo raw

df <- read_rds('./data/raw_data_eph.rds')

###
df <- df %>%
  organize_labels(type = "individual")


#df <- read_rds('./data/proc_data_eph.rds')
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
      (
        aportes == 1 & descuentos == 1), 1, 1, 0)
    )

df <- df %>%
  mutate(la_rioja_aglo = if_else(AGLOMERADO == "La Rioja", "La Rioja", "Resto"),
         la_rioja_region = case_when(
           AGLOMERADO == "La Rioja" ~ "2. La Rioja", 
           AGLOMERADO != "La Rioja" & REGION == "Noroeste" ~ "1. NOA-Resto",
           TRUE ~ "3. Resto país"))


### Salva archivo final
#df %>% write_rds('./data/proc_data_eph.rds')

## para mí hay que ir bajando cada onda eph, calculando la tasa 
# y agregándola a un archivo csv con la serie temporal


### Tablas y gráficos
## Evolucion indicador NED
library(eph)
library(tidyverse)
library(lubridate)


nombres_aglomerados <- df %>% select(la_rioja_region) %>% distinct()%>% pull()
#nombres_aglomerados[order(names(nombres_aglomerados))]
nombres_aglomerados<-nombres_aglomerados[order(nombres_aglomerados)]
colores <- sub("FF$", "99", viridis::rocket(length(nombres_aglomerados)))

names(colores)<-nombres_aglomerados

colores["2. La Rioja"] <- "#E84A2F"  # warm coral-red: contrasts with blue-gren-yellow viridis

df %>%
  group_by(fecha, REGION, AGLOMERADO, la_rioja_region) %>%
  summarise(value = mean(mayor_25_superior)) %>%
  ggplot() + 
    geom_line(aes(x=fecha, y=value, group=AGLOMERADO, color=la_rioja_region), 
              show.legend = TRUE) +
  scale_color_manual(values = colores, name = "Region") +
  labs(x="Año-Trimestre", 
       y="% de personas mayores de 25 años con estudios superiores completos") +
    theme_minimal() +
  theme(axis.text.x = element_text(size=6, angle = 45, hjust = 1))

