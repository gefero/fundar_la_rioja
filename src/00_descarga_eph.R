library(eph)
library(tidyverse)
source("./src/utils_eph.R")

## Descarga incremental de microdatos EPH (individuo y hogar), 2007-2025.
## Si un archivo ya existe en disco, se omite su descarga.

vars_individuo <- c("ANO4", "TRIMESTRE","CODUSU", "NRO_HOGAR", "COMPONENTE", ## identificadores
                     "REGION", "AGLOMERADO", "PONDERA", # region
                     "CH03", "CH04", "CH06", "NIVEL_ED", "CH10", "CH12", "CH13", "CH14", # demográficas
                     "ESTADO", "CAT_OCUP", # laborales
                     "PP04C", "PP04C99", # informalidad tamaño
                     "PP07H", "PP07I", # informalidad registro
                     "PP03C")

vars_hogar <- c("ANO4", "TRIMESTRE","CODUSU", "NRO_HOGAR", ## identificadores
                 "REGION", "AGLOMERADO", "PONDERA", # region
                 "IV1","IV2", # vivienda
                 "IV4", "IV5", "IV6", "IV7", "IV8", "IV9", "IV10", "IV11", # saneamiento
                 "II1", "II2", # hacinamiento
                 "IX_TOT") # Total miembros

descargar_eph_incremental(vars_individuo, type = "individual",
                           out_dir = "./data/raw_data/eph/individuo")

descargar_eph_incremental(vars_hogar, type = "hogar",
                           out_dir = "./data/raw_data/eph/hogar")
