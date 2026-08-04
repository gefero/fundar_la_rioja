# =============================================================================
# TALLER DE VISUALIZACIÓN — VERIFICACIÓN DEL ENTORNO
# -----------------------------------------------------------------------------
# Correr ESTE script ANTES de la primera clase.
#
# Cómo correrlo:
#   1. Abrir `fundar_larioja.Rproj` en RStudio (esto fija el directorio de
#      trabajo en la raíz del repo, que es lo que asumen todas las rutas).
#   2. source("clases/materiales/00_setup.R")
#
# Si termina con "✔ Todo listo", estás en condiciones de hacer la práctica.
# =============================================================================

cat("\n=== 1. Versión de R ===\n")
cat(R.version.string, "\n")
if (getRversion() < "4.1.0") {
  warning("Se recomienda R >= 4.1 (el pipeline usa el pipe nativo en algunos lugares).")
}

# -----------------------------------------------------------------------------
# 2. Paquetes
# -----------------------------------------------------------------------------
# Se instalan solo los que falten, para no re-bajar todo en cada corrida.

cat("\n=== 2. Paquetes ===\n")

paquetes <- c(
  # Práctica de las tres clases
  "tidyverse",    # dplyr, ggplot2, readr, tidyr...
  "ggrepel",      # etiquetas sin solapamiento (lo usa src/03b_...)
  "scales",       # formateo de ejes
  "lubridate",    # fechas
  # Clase 2: auditoría de paletas
  "farver",       # distancias perceptuales entre colores (ΔE)
  "colorspace",   # simulación de daltonismo
  # Clase 3: pipeline y dashboard
  "eph",          # microdatos EPH (solo para la demo)
  "readxl",       # lectura de los xlsx del SIPA
  "tictoc",
  "here",
  "shiny", "bslib", "bsicons", "plotly"
)

faltantes <- setdiff(paquetes, rownames(installed.packages()))

if (length(faltantes) > 0) {
  cat("Instalando:", paste(faltantes, collapse = ", "), "\n")
  install.packages(faltantes)
} else {
  cat("Todos los paquetes ya estaban instalados.\n")
}

# Se vuelve a chequear después de instalar: si algo falló, mejor enterarse ahora
# y no en el medio de la clase.
faltantes <- setdiff(paquetes, rownames(installed.packages()))
if (length(faltantes) > 0) {
  stop("No se pudieron instalar: ", paste(faltantes, collapse = ", "),
       "\nProbá instalarlos a mano con install.packages().")
}

# ggplot2 >= 3.4 es requisito real, no una recomendación: el argumento
# `linewidth` (que usan todos los scripts del repo, no solo la práctica)
# reemplazó a `size` en esa versión.
if (packageVersion("ggplot2") < "3.4.0") {
  stop("Se necesita ggplot2 >= 3.4.0 (tenés ", packageVersion("ggplot2"), ").\n",
       "Actualizalo con install.packages('ggplot2').")
}
cat("ggplot2:", format(packageVersion("ggplot2")), "\n")

# -----------------------------------------------------------------------------
# 3. Datos y estilo
# -----------------------------------------------------------------------------
# La práctica trabaja SOLO sobre los CSV versionados de data/inputs_md/.
# No hace falta descargar microdatos de la EPH.

cat("\n=== 3. Datos y estilo ===\n")

if (!file.exists("fundar_larioja.Rproj")) {
  stop("No parece que el directorio de trabajo sea la raíz del repo.\n",
       "Abrí fundar_larioja.Rproj en RStudio y volvé a correr este script.\n",
       "Directorio actual: ", getwd())
}

csvs_necesarios <- c(
  "data/inputs_md/04_tasa_desoc.csv",
  "data/inputs_md/10_tasa_empleo.csv",
  "data/inputs_md/13a_nbi_hogares.csv",
  "data/inputs_md/03b_salarios_registrados_EPH.csv",
  "data/inputs_md/05_puestos_asalariados_privados.csv"
)

faltan_csv <- csvs_necesarios[!file.exists(csvs_necesarios)]
if (length(faltan_csv) > 0) {
  stop("Faltan datos de la práctica:\n  ", paste(faltan_csv, collapse = "\n  "),
       "\nAsegurate de tener el repo actualizado (git pull).")
}
cat("Los", length(csvs_necesarios), "CSV de la práctica están presentes.\n")

if (!file.exists("style/fundar_monitor_theme.R")) {
  stop("No se encuentra style/fundar_monitor_theme.R")
}

# -----------------------------------------------------------------------------
# 4. Gráfico de prueba
# -----------------------------------------------------------------------------
# Reproduce en chiquito lo que hace src/04_desoc.R. Si esto dibuja, todo el
# resto de la práctica va a funcionar.

cat("\n=== 4. Gráfico de prueba ===\n")

suppressPackageStartupMessages(library(tidyverse))
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/04_tasa_desoc.csv", show_col_types = FALSE)

p <- df %>%
  ggplot(aes(x = fecha, y = tasa_desoc,
             group = la_rioja_region, color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  theme_monitor() +
  labs(title = "Prueba de entorno — tasa de desocupación",
       x = "Año-Trimestre", y = "%",
       caption = fuente_fundar("EPH-INDEC"))

print(p)

cat("\n✔ Todo listo. Deberías estar viendo un gráfico de tres líneas en el panel Plots.\n")
cat("  Si lo ves, estás en condiciones de hacer la práctica del taller.\n\n")
