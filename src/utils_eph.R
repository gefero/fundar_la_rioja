library(eph)
library(tidyverse)

## Descarga incremental: baja un trimestre a la vez, saltea los que ya existen en disco.
## `type` es el valor que espera eph::get_microdata() ("individual" o "hogar").
## `file_tag` es la etiqueta usada en el nombre del archivo (ej. "individuo"), que
## puede diferir de `type` -- deben mantenerse separados para que file.exists()
## compare contra el nombre real de los .rds ya descargados.
## `years` por defecto llega hasta el año en curso, así una onda nueva de la EPH
## se intenta descargar sola sin tener que editar el rango a mano cada año.
## Si un trimestre todavía no está publicado en INDEC, get_microdata() falla:
## se captura el error, se avisa por consola y se sigue con el resto (no corta
## el loop ni pierde lo ya descargado en trimestres anteriores).
descargar_eph_incremental <- function(vars, type, out_dir, file_tag = type,
                                       years = 2007:as.integer(format(Sys.Date(), "%Y")),
                                       periods = 1:4) {
  periodos <- expand_grid(year = years, period = periods)
  tictoc::tic()
  for (i in seq_len(nrow(periodos))) {
    y <- periodos$year[[i]]
    p <- periodos$period[[i]]
    out <- file.path(out_dir, paste0(y, "_", p, "_EPH_", file_tag, ".rds"))
    if (file.exists(out)) {
      cat("El archivo existe:", out, "\n")
      next
    }
    cat("Descargando", out, "\n")
    tryCatch({
      df <- get_microdata(period = p, year = y, type = type, vars = vars)
      write_rds(df, out)
    }, error = function(e) {
      cat("No se pudo descargar", out, "- probablemente todavía no está publicado. Detalle:",
          conditionMessage(e), "\n")
    })
  }
  tictoc::toc()
}

## Saca la clase "labelled" (expss/haven) y sus atributos de etiqueta de una
## columna, si los tiene. organize_labels() deja MUCHAS columnas numéricas
## (no solo las categóricas) como labelled, lo cual rompe operaciones
## aritméticas y comparaciones de tipo estrictas más adelante (if_else(),
## left_join()...) apenas se mezclan con valores planos (ej. Inf) o entre
## dos bases etiquetadas por separado (individuo vs hogar).
quitar_labelled <- function(x) {
  if (inherits(x, "labelled")) {
    x <- unclass(x)
    attributes(x) <- attributes(x)[intersect(names(attributes(x)), "names")]
  }
  x
}

## Carga todos los .rds crudos de una carpeta, une, etiqueta y limpia variables comunes.
limpiar_base_eph <- function(files_dir, type, cols_a_character) {
  files <- list.files(files_dir, pattern = "\\.rds$", full.names = TRUE)
  df <- files %>%
    map(read_rds) %>%
    bind_rows()

  df <- df %>%
    organize_labels(type = type) %>%
    mutate(across(everything(), quitar_labelled))

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
