# =============================================================================
# CLASE 1 — EJERCICIO 2: tres mapeos del mismo dato
# -----------------------------------------------------------------------------
# 13a_nbi_hogares.csv tiene el % de hogares con NBI TOTAL y las 5
# sub-dimensiones. Hoy src/13a_nbi_hogares.R grafica SOLO el total.
#
# Vamos a mapear las mismas variables de tres formas distintas y decidir a qué
# pregunta responde mejor cada una.
#
# LA CONSIGNA NO ES "CUÁL ES MÁS LINDA". Es: ¿qué pregunta contesta bien cada
# versión, y cuál contesta mal?
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/13a_nbi_hogares.csv", show_col_types = FALSE)

glimpse(df)
# pct_hogares_NBI_TOT + pct_hogares_NBI_{HAC, VIV, SAN, ESC, SUB}


# ---- Preparación: de formato ancho a formato largo --------------------------
# ggplot necesita UNA fila por (trimestre, región, dimensión). Hoy las
# dimensiones son 6 columnas distintas: hay que apilarlas.
# (Este paso —pivot_longer— es el 80% del trabajo de preparar datos para
# graficar. Vale la pena leerlo con calma.)

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
    fecha = lubridate::yq(fecha)   # a fecha real, para que el eje x respire
  ) %>%
  filter(dimension != "Total")     # las 5 sub-dimensiones; el total ya se grafica

glimpse(df_largo)


# =============================================================================
# VERSIÓN A — color = dimensión, un panel por región
# =============================================================================
# TODO: completá el aes() y el facet_wrap().
#   - color debe mapear a `dimension`
#   - el facetado debe partir por `la_rioja_region`

df_largo %>%
  ggplot(aes(x = fecha, y = pct,
             group = dimension,
             color = ______)) +          # <-- TODO
  geom_line(linewidth = 0.6) +
  facet_wrap(~ ______) +                  # <-- TODO
  theme_monitor() +
  labs(title = "Versión A — una dimensión por color, un panel por región",
       x = NULL, y = "% de hogares",
       caption = fuente_fundar("EPH-INDEC"))

# PREGUNTA: mirando el panel de La Rioja, ¿podés decir qué privación pesa más?


# =============================================================================
# VERSIÓN B — color = región, un panel por dimensión
# =============================================================================
# TODO: es la versión A dada vuelta. Cambiá qué va al color y qué al facet.
#       Usá scale_color_fundar_multi() para que La Rioja se destaque.

df_largo %>%
  ggplot(aes(x = fecha, y = pct,
             group = ______,             # <-- TODO
             color = ______)) +          # <-- TODO
  geom_line(linewidth = 0.6) +
  scale_color_fundar_multi(name = "Región") +
  facet_wrap(~ ______, scales = "free_y") +   # <-- TODO
  theme_monitor() +
  labs(title = "Versión B — una región por color, un panel por dimensión",
       x = NULL, y = "% de hogares",
       caption = fuente_fundar("EPH-INDEC"))

# PREGUNTA: ¿podés decir si La Rioja está mejor o peor que el NOA en
#           hacinamiento? ¿Y en la versión A?
# PREGUNTA: `scales = "free_y"` hace que cada panel tenga su propia escala.
#           ¿Qué se gana y qué se pierde con eso?


# =============================================================================
# VERSIÓN C — todo superpuesto: color = región, linetype = dimensión
# =============================================================================
# Sin facetado: dos canales sobre la misma marca, en un solo panel.

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

# PREGUNTAS:
#   - ¿Cuántas series hay dibujadas? (contá: regiones × dimensiones)
#   - Mirando la slide 37 del deck: matiz + tipo de línea, ¿son separables?
#   - ¿Podés seguir UNA serie de punta a punta?


# =============================================================================
# PARA LA PUESTA EN COMÚN
# =============================================================================
# Completá:
#
# | Versión | ¿Qué pregunta contesta BIEN? | ¿Qué pregunta contesta MAL? |
# |---------|------------------------------|------------------------------|
# | A       |                              |                              |
# | B       |                              |                              |
# | C       |                              |                              |
