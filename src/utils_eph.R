library(eph)
library(tidyverse)

## Descarga incremental: baja un trimestre a la vez, saltea los que ya existen en disco.
descargar_eph_incremental <- function(vars, type, out_dir, years = 2007:2025, periods = 1:4) {
  periodos <- expand_grid(year = years, period = periods)
  tictoc::tic()
  for (i in seq_len(nrow(periodos))) {
    y <- periodos$year[[i]]
    p <- periodos$period[[i]]
    out <- file.path(out_dir, paste0(y, "_", p, "_EPH_", type, ".rds"))
    if (file.exists(out)) {
      cat("El archivo existe:", out, "\n")
      next
    }
    cat("Descargando", out, "\n")
    df <- get_microdata(period = p, year = y, type = type, vars = vars)
    write_rds(df, out)
  }
  tictoc::toc()
}

## Carga todos los .rds crudos de una carpeta, une, etiqueta y limpia variables comunes.
limpiar_base_eph <- function(files_dir, type, cols_a_character) {
  files <- list.files(files_dir, pattern = "\\.rds$", full.names = TRUE)
  df <- files %>%
    map(read_rds) %>%
    bind_rows()

  df <- df %>%
    organize_labels(type = type)

  df %>%
    mutate(across(all_of(cols_a_character), as.character)) %>%
    mutate(
      ANO4 = as.numeric(ANO4),
      TRIMESTRE = unclass(TRIMESTRE),
      fecha = paste0(ANO4, "-Q", TRIMESTRE)
    )
}

## Clasifica aglomerado/región en 3 grupos: La Rioja, NOA-Resto y Resto país.
asignar_la_rioja_region <- function(df) {
  df %>%
    mutate(la_rioja_region = case_when(
      AGLOMERADO == "La Rioja" ~ "3. La Rioja",
      AGLOMERADO != "La Rioja" & REGION == "Noroeste" ~ "2. NOA-Resto",
      TRUE ~ "1. Resto país"
    ))
}
