# =============================================================================
# CLASE 3 - SOLUCIÓN · Bloque A, Parte 1: gráfico de líneas del monitor
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/12_mayor_25_superior.csv", show_col_types = FALSE)


# ---- Paso 1: preparar los datos ----------------------------------------

df_plot <- df %>%
  mutate(
    fecha           = lubridate::yq(fecha),   # TODO 1: "2007-Q1" -> 2007-01-01 (Date)
    la_rioja_region = factor(la_rioja_region)
  )


# ---- Paso 2: el gráfico -----------------------------------------------

df_plot %>%
  ggplot(aes(x = fecha, y = porc_mayor_25_superior,
             group = la_rioja_region, color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +   # TODO 2
  ylim(0, 35) +
  theme_monitor() +
  labs(
    # TODO 3 - título provisorio. La versión publicable (Bloque B) sería algo como:
    #   "La Rioja alcanzó al resto del país en educación superior recién en la última década"
    title   = "Población de +25 años con estudios superiores completos",
    x       = NULL,
    y       = "% de personas mayores de 25 años",
    caption = fuente_fundar("EPH-INDEC")
  )

# ggsave("outputs/plots/12_educ.png", width = 12, height = 8)


# =============================================================================
# RESPUESTAS
# =============================================================================
# 1. Depende de la serie, pero en general el eje X (decisión 1): pasar de 75
#    etiquetas de texto rotadas a 8 años legibles es lo que más cambia la
#    lectura. La paleta (decisión 4) es la segunda.
#
# 2. `quiebres_x <- quiebres_x[grepl("Q1$|Q3$", quiebres_x)]` se queda con los
#    trimestres cuyo texto termina en "Q1" o "Q3" -> 2 marcas por año en vez
#    de 4. Funciona porque `fecha` es texto y el orden alfabético de "YYYY-Qn"
#    coincide con el cronológico. scale_x_date() es más robusto: no depende de
#    ese formato de string y sigue eligiendo marcas razonables si el dato pasa
#    a ser mensual, o si cambia el rango de años.
#
# 3. Sin la paleta del proyecto, ggplot asigna tres colores de peso visual
#    parecido y hay que LEER la leyenda para ubicar La Rioja. Con
#    scale_color_fundar_multi(), La Rioja es el único tono oscuro y salta sola.
