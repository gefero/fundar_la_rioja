# =============================================================================
# CLASE 1 — EJERCICIO 2: SOLUCIÓN
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/13a_nbi_hogares.csv", show_col_types = FALSE)

df_largo <- df %>%
  select(fecha, la_rioja_region, starts_with("pct_hogares_NBI_")) %>%
  pivot_longer(
    cols      = starts_with("pct_hogares_NBI_"),
    names_to  = "dimension",
    values_to = "pct"
  ) %>%
  mutate(
    dimension = str_remove(dimension, "pct_hogares_NBI_"),
    dimension = recode(dimension,
                       TOT = "Total",
                       HAC = "Hacinamiento",
                       VIV = "Vivienda",
                       SAN = "Sanitarias",
                       ESC = "Escolaridad",
                       SUB = "Subsistencia"),
    fecha = lubridate::yq(fecha)
  ) %>%
  filter(dimension != "Total")


# ---- VERSIÓN A: color = dimensión, panel = región ---------------------------

df_largo %>%
  ggplot(aes(x = fecha, y = pct,
             group = dimension,
             color = dimension)) +
  geom_line(linewidth = 0.6) +
  facet_wrap(~ la_rioja_region) +
  theme_monitor() +
  labs(title = "Versión A — una dimensión por color, un panel por región",
       x = NULL, y = "% de hogares",
       caption = fuente_fundar("EPH-INDEC"))


# ---- VERSIÓN B: color = región, panel = dimensión ---------------------------

df_largo %>%
  ggplot(aes(x = fecha, y = pct,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.6) +
  scale_color_fundar_multi(name = "Región") +
  facet_wrap(~ dimension, scales = "free_y") +
  theme_monitor() +
  labs(title = "Versión B — una región por color, un panel por dimensión",
       x = NULL, y = "% de hogares",
       caption = fuente_fundar("EPH-INDEC"))


# ---- VERSIÓN C: todo superpuesto --------------------------------------------

df_largo %>%
  ggplot(aes(x = fecha, y = pct,
             group    = interaction(la_rioja_region, dimension),
             color    = la_rioja_region,
             linetype = dimension)) +
  geom_line(linewidth = 0.6) +
  scale_color_fundar_multi(name = "Región") +
  theme_monitor() +
  labs(title = "Versión C — todo en un panel",
       x = NULL, y = "% de hogares",
       caption = fuente_fundar("EPH-INDEC"))


# =============================================================================
# DISCUSIÓN
# =============================================================================
#
# | Versión | Contesta BIEN                          | Contesta MAL                        |
# |---------|----------------------------------------|-------------------------------------|
# | A       | "Dentro de La Rioja, ¿qué privación     | "¿La Rioja está mejor o peor que el |
# |         | pesa más?" — las 5 dimensiones          | NOA en hacinamiento?" — hay que     |
# |         | comparten eje dentro de cada panel      | saltar entre paneles                |
# | B       | "¿Cómo se compara La Rioja con el NOA   | "¿Qué privación pesa más en La      |
# |         | en cada privación?" — las 3 regiones    | Rioja?" — con free_y cada panel     |
# |         | comparten eje dentro de cada panel      | tiene su propia escala              |
# | C       | Casi nada: 15 series en un panel        | Todo                                |
#
# La regla general: LO QUE COMPARTE PANEL ES LO QUE SE COMPARA BIEN, porque
# comparte escala. Elegir qué va al facetado y qué al color ES elegir qué
# comparación querés hacer fácil. No hay versión "correcta" en abstracto:
# depende de la pregunta.
#
# Sobre `scales = "free_y"` en la versión B: se gana resolución (las dimensiones
# chicas —Vivienda, Sanitarias— tienen valores mucho menores que Hacinamiento y
# con escala común quedarían aplastadas contra el cero), y se pierde la
# comparación ENTRE paneles: dos líneas que se ven igual de altas pueden estar
# en órdenes de magnitud distintos. Si se usa free_y hay que decirlo en el
# subtítulo.
#
# Sobre la versión C: son 3 regiones × 5 dimensiones = 15 series. Matiz y tipo
# de línea NO son separables a esta densidad (slide 37): con 15 combinaciones el
# ojo no decodifica dos canales, ve una maraña. Además el tipo de línea es un
# canal de muy baja discriminabilidad: 5 valores es más de lo que soporta.
