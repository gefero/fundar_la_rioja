# =============================================================================
# CLASE 1 - EJERCICIO 3: romper el gráfico a propósito
# -----------------------------------------------------------------------------
# Comprobamos en carne propia la jerarquía de canales de Munzner (slides 33-45
# del deck): codificamos la MISMA variable con tres canales distintos y medimos
# (a ojo, honestamente) cuánto cuesta leer cada versión.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/10_tasa_empleo.csv", show_col_types = FALSE) %>%
  mutate(fecha = lubridate::yq(fecha))


# =============================================================================
# VERSIÓN A - región mapeada a COLOR (matiz + luminancia)
# =============================================================================
# Es lo que hace el repo.

df %>%
  ggplot(aes(x = fecha, y = tasa_empleo,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  theme_monitor() +
  labs(title = "A - región por COLOR", x = NULL, y = "Tasa de empleo (%)")

# CRONOMETRATE: ¿cuánto tardás en encontrar la serie de La Rioja?


# =============================================================================
# VERSIÓN B - región mapeada a FORMA del punto
# =============================================================================
# La forma es, según Munzner, el PEOR canal para variables categóricas.
# Necesitamos puntos (la forma no se puede aplicar a una línea).

df %>%
  ggplot(aes(x = fecha, y = tasa_empleo,
             group = la_rioja_region,
             shape = la_rioja_region)) +
  geom_line(linewidth = 0.4, color = "grey40") +
  geom_point(size = 1.6, color = "grey20") +
  theme_monitor() +
  labs(title = "B - región por FORMA", x = NULL, y = "Tasa de empleo (%)")

# PREGUNTAS:
#   - ¿Cuánto tardás ahora en encontrar La Rioja?
#   - Donde dos series se cruzan, ¿podés seguirlas?
#   - ¿Distinguirías SEIS regiones con este canal?


# =============================================================================
# VERSIÓN C - región mapeada a TAMAÑO (grosor de línea)
# =============================================================================
# El tamaño tiene ordinalidad implícita: sugiere que una categoría es "más"
# que otra. Para una variable puramente categórica, eso es información falsa.

df %>%
  ggplot(aes(x = fecha, y = tasa_empleo,
             group     = la_rioja_region,
             linewidth = la_rioja_region)) +
  geom_line(color = "grey25") +
  scale_linewidth_manual(values = c(0.4, 0.9, 1.6), name = "Región") +
  theme_monitor() +
  labs(title = "C - región por TAMAÑO", x = NULL, y = "Tasa de empleo (%)")

# PREGUNTA: ¿qué te sugiere que "3. La Rioja" sea la línea más gruesa?
#           ¿Es información que está en los datos o la agregó el gráfico?


# =============================================================================
# BONUS - la misma paleta, sin contraste de luminancia
# =============================================================================
# Volvemos a la versión A, pero con tres colores de LUMINANCIA PAREJA. El matiz
# sigue distinguiendo las regiones... pero La Rioja deja de saltar a la vista.
#
# Ese contraste es exactamente lo que la paleta del proyecto está diseñada
# para producir (ver style/fundar_monitor_theme.R:25-31).

PALETA_PLANA <- c("#7FB3D5", "#7FD5A8", "#D5B37F")   # tres tonos, misma luminancia

df %>%
  ggplot(aes(x = fecha, y = tasa_empleo,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_manual(values = PALETA_PLANA, name = "Región") +
  theme_monitor() +
  labs(title = "BONUS - misma paleta, sin contraste de luminancia",
       x = NULL, y = "Tasa de empleo (%)")

# PREGUNTA FINAL: compará esta con la versión A. ¿Cuál usarías en un informe
# donde el protagonista es La Rioja? ¿Y en uno que compara las tres regiones
# en pie de igualdad?
