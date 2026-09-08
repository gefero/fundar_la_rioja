# =============================================================================
# CLASE 3 - BLOQUE A, PARTE 1: gráfico de líneas del monitor
# -----------------------------------------------------------------------------
# Reconstruye src/12_educ.R sobre un CSV nuevo. La gramática de líneas ya se
# vio entera en la clase 1; acá el foco está en las CUATRO decisiones que
# convierten un gráfico de exploración en uno del monitor.
#
# Corré este script desde la raíz del repo (abrí fundar_larioja.Rproj), de a
# un bloque por vez con Ctrl+Enter, mirando el gráfico en cada paso.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/12_mayor_25_superior.csv", show_col_types = FALSE)

glimpse(df)
# fecha                      : el trimestre, como TEXTO ("2007-Q1")
# la_rioja_region            : "1. Resto país" / "2. NOA-Resto" / "3. La Rioja"
# mayor_25_superior, pob_tot : los totales ponderados con los que se calculó
# porc_mayor_25_superior     : el indicador (% de +25 con superior completo)


# ---- Paso 0: el gráfico crudo --------------------------------------------
# Sin ninguna de las cuatro decisiones. Mirá los problemas: el eje X es
# ilegible, el eje Y no arranca en cero, los colores no destacan a La Rioja.

ggplot(df, aes(x = fecha, y = porc_mayor_25_superior,
               group = la_rioja_region, color = la_rioja_region)) +
  geom_line(linewidth = 0.7)


# ---- Paso 1: preparar los datos -----------------------------------------
# DECISIÓN 1 - fecha a fecha real. `fecha` es texto: ggplot trata cada
#   trimestre como categoría y dibuja 75 etiquetas. Con Date, ggplot elige
#   marcas cada N años.
# DECISIÓN 2 - factor(la_rioja_region). Fuerza el orden 1 < 2 < 3, así La
#   Rioja se dibuja última y queda por encima cuando las líneas se cruzan.
#
# TODO 1: convertí `fecha` a Date con lubridate::yq() (year-quarter).

df_plot <- df %>%
  mutate(
    fecha           = ______,                         # <-- TODO 1
    la_rioja_region = factor(la_rioja_region)          # DECISIÓN 2
  )


# ---- Paso 2: el gráfico -------------------------------------------------
# DECISIÓN 3 - ylim(0, 35): el eje Y arranca en cero (integridad visual).
# DECISIÓN 4 - scale_color_fundar_multi(): la paleta del proyecto, que
#   destaca a La Rioja por contraste de luminancia.
#
# TODO 2: en scale_x_date(), elegí un date_breaks legible ("2 years" anda bien).
# TODO 3: poné un título provisorio (en el Bloque B de narrativa se reescribe
#         para publicar).

df_plot %>%
  ggplot(aes(x = fecha, y = porc_mayor_25_superior,
             group = la_rioja_region, color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +          # DECISIÓN 4
  scale_x_date(date_labels = "%Y", date_breaks = "______") +   # <-- TODO 2
  ylim(0, 35) +                                        # DECISIÓN 3
  theme_monitor() +
  labs(
    title   = "______",                               # <-- TODO 3
    x       = NULL,
    y       = "% de personas mayores de 25 años",
    caption = fuente_fundar("EPH-INDEC")
  )

# ggsave("outputs/plots/12_educ.png", width = 12, height = 8)


# =============================================================================
# PREGUNTAS
# =============================================================================
# 1. Compará el Paso 0 con el Paso 2. ¿Cuál de las cuatro decisiones tuvo más
#    impacto en la legibilidad?
#
# 2. src/12_educ.R usa scale_x_discrete(breaks = quiebres_x) en vez de
#    scale_x_date(). Abrilo. ¿Qué hace ese truco con grepl("Q1$|Q3$")?
#    ¿Por qué scale_x_date() es más robusto si mañana hay datos mensuales?
#
# 3. Sacá scale_color_fundar_multi(). ¿Cuánto tardás en encontrar La Rioja?
