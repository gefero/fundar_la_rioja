library(eph)
library(tidyverse)
library(lubridate)

## Descarga datos
vars <- c("ANO4", "TRIMESTRE","CODUSU", "NRO_HOGAR", ## identificadores
          "REGION", "AGLOMERADO", "PONDERA", # region
          "IV1","IV2", # vivienda
          "IV4", "IV5", "IV6", "IV7", "IV8", "IV9", "IV10", "IV11" , # saneamiento 
          "II1", "II2", # hacinamiento
          "IX_TOT" # Total miembros
          )

periods <- expand_grid(year = 2007:2025, period = 1:4)
tictoc::tic()
for (i in 1:nrow(periods)){
  p <- periods$period[[i]]
  y <- periods$year[[i]]
  
  out <- paste0('./data/raw_data/eph/hogar/', y, "_", p, "_EPH_hogar.rds")
  
  if (!file.exists(out)){
    
    cat("El archivo no existe. Descargando ", out , "\n")
    df <- get_microdata(
      period = p,
      year = y,
      type = "hogar",
      vars = vars
    ) 
    
    df %>% write_rds(out)
  } else {
    cat("El archivo existe...", "\n")
    next
  }
}
tictoc::toc()

# 1. Get a list of all CSV files with their full system paths
files <- list.files(path = "./data/raw_data/eph/hogar/", 
                    pattern = "\\.rds$", 
                    full.names = TRUE)

### Carga archivo raw
df <- files %>% 
  map(read_rds) %>% 
  bind_rows()

## Preprocesamiento
### Agrega etiquetas
df <- df %>%
  organize_labels(type = "hogar")

## Transforma variables clave
df <- df %>%
  mutate(across(REGION:II2, ~as.character(.x))) %>%
  mutate(ANO4 = as.numeric(ANO4),
    TRIMESTRE = unclass(TRIMESTRE)) %>%
  mutate(fecha = paste0(ANO4, "-0", TRIMESTRE))

