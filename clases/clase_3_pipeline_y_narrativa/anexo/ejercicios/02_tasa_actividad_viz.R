# =============================================================================
# CLASE 3 - PASO 4: el gráfico del indicador nuevo
# -----------------------------------------------------------------------------
# Copiá este archivo a src/06_tasa_actividad.R y completá los TODO.
#
# Seguí el patrón de src/04_desoc.R, aplicando lo que aprendimos en las clases
# 1 y 2. Los textos los escribe el perfil comunicación (paso 3).
# =============================================================================

library(tidyverse)
source("./style/fundar_monitor_theme.R")

df <- read_csv("./data/inputs_md/06_tasa_actividad.csv", show_col_types = FALSE)


# ---- Preparación ------------------------------------------------------------
# TODO 1: convertí `fecha` a Date. Hoy es texto ("2007-Q1") y por eso los
#         gráficos del repo tienen 72 etiquetas rotadas en el eje X (el caso de
#         visual cluttering que vimos en la clase 2).
#         Pista: lubridate::yq()

df_plot <- df %>%
  mutate(fecha = ______)                     # <-- TODO 1


# ---- El gráfico -------------------------------------------------------------
# TODO 2: completá el mapeo estético. Tres variables: tiempo, tasa y región.
# TODO 3: elegí los breaks del eje X para que sea legible.
# TODO 4: pegá acá los textos del paso 3.

df_plot %>%
  ggplot(aes(x = ______,                     # <-- TODO 2
             y = ______,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  scale_x_date(date_labels = "%Y", date_breaks = "______") +   # <-- TODO 3
  ylim(0, 55) +                              # el eje Y arranca en cero
  theme_monitor() +
  labs(
    title    = "______",                     # <-- TODO 4: el hallazgo, afirmado
    subtitle = "______",                     # <-- TODO 4: unidad, universo, período
    x        = NULL,
    y        = "Tasa de actividad (%)",
    caption  = fuente_fundar("______")       # <-- TODO 4: fuente + advertencias
  )

ggsave("./outputs/plots/06_tasa_actividad.png", width = 12, height = 7)


# =============================================================================
# EXTRA - el gráfico que cuenta la historia completa
# =============================================================================
# Empleo, desocupación y actividad son tres caras del mismo fenómeno. Un
# gráfico facetado de las tres series para La Rioja cuenta una historia que
# ninguna de las tres cuenta sola: si la actividad sube y el empleo no la
# acompaña, la desocupación sube.
#
# Descomentalo si te sobra tiempo.

# desoc  <- read_csv("./data/inputs_md/04_tasa_desoc.csv",  show_col_types = FALSE)
# empleo <- read_csv("./data/inputs_md/10_tasa_empleo.csv", show_col_types = FALSE)
#
# bind_rows(
#   df     %>% transmute(fecha, la_rioja_region, serie = "Actividad",    valor = tasa_actividad),
#   empleo %>% transmute(fecha, la_rioja_region, serie = "Empleo",       valor = tasa_empleo),
#   desoc  %>% transmute(fecha, la_rioja_region, serie = "Desocupación", valor = tasa_desoc)
# ) %>%
#   filter(la_rioja_region == "3. La Rioja") %>%
#   mutate(fecha = lubridate::yq(fecha),
#          serie = factor(serie, levels = c("Actividad", "Empleo", "Desocupación"))) %>%
#   ggplot(aes(x = fecha, y = valor)) +
#   geom_line(color = unname(FUNDAR_MULTI["serie_3"]), linewidth = 0.7) +
#   facet_wrap(~ serie, ncol = 1, scales = "free_y") +
#   scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
#   theme_monitor() +
#   labs(title = "Actividad, empleo y desocupación en La Rioja",
#        x = NULL, y = "%",
#        caption = fuente_fundar("Fundar, con base en la EPH (INDEC)."))
#
# PREGUNTA: acá usamos `scales = "free_y"`, que rompe la regla del eje en cero.
# Según el informe de Argendata, ¿está justificado en este caso? ¿Por qué?
