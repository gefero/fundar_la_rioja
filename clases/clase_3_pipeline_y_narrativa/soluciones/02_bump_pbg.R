# =============================================================================
# CLASE 3 - SOLUCIÓN · Bloque A, Parte 2: bump chart del ranking de PBG per cápita
# -----------------------------------------------------------------------------
# Versión simplificada de src/15_pbg_ranking_percapita.R (ese script destaca
# La Rioja + las 5 provincias del NOA con un color cada una; acá agrupamos el
# contexto en las tres regiones del monitor, que es más simple de leer).
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

prov <- read_csv(
  "data/inputs_md/15_pbg_per_capita_por_provincia.csv",
  show_col_types = FALSE
)


# ---- Paso 1: de valor a ranking (TODO 1) ------------------------------

rank_df <- prov %>%
  group_by(anio) %>%
  mutate(ranking = min_rank(desc(pbg_per_capita))) %>%   # 1 = PBG pc más alto
  ungroup() %>%
  arrange(la_rioja_region, provincia, anio)              # La Rioja se dibuja encima

rank_df %>% count(anio) %>% pull(n) %>% unique()          # -> 24 (chequeo)


# ---- Paso 4: el gráfico terminado -----------------------------------
# (los pasos 2 y 3 son builds intermedios; este es el resultado)

etiqueta_lr <- rank_df %>%
  filter(anio == max(anio), provincia == "La Rioja")      # TODO 4

ggplot(rank_df, aes(x = anio, y = ranking, group = provincia,
                    color = la_rioja_region)) +
  geom_line(aes(linewidth = la_rioja_region)) +
  geom_point(size = 1.2, show.legend = FALSE) +
  geom_text(
    data = etiqueta_lr,
    aes(label = paste0("La Rioja (", ranking, "°)")),
    hjust = -0.1, size = 3.2, fontface = "bold", show.legend = FALSE
  ) +
  scale_y_reverse(breaks = 1:24) +                         # TODO 2
  scale_color_fundar_multi(name = "Región") +
  scale_linewidth_manual(values = c(0.3, 0.5, 1.4), guide = "none") +  # TODO 3
  scale_x_continuous(breaks = seq(2010, 2024, 2),
                     expand = expansion(mult = c(0.02, 0.15))) +
  coord_cartesian(clip = "off") +
  theme_monitor() +
  theme(plot.margin = margin(16, 80, 16, 16)) +
  labs(
    # El hallazgo depende de lo que muestre la serie al correrla. Un título
    # honesto suele ser del tipo:
    #   "La Rioja se mantiene entre las provincias de menor PBG per cápita, sin
    #    cambios de posición sostenidos en la última década"
    title    = "Ranking provincial de PBG per cápita — posición de La Rioja",
    subtitle = "Puesto entre las 24 jurisdicciones · PBG per cápita en pesos constantes de 2004 · 2010–2024",
    x = NULL, y = "Puesto (1 = mayor PBG per cápita)",
    caption  = fuente_fundar(
      "Fundar, con base en CEPAL / Ministerio de Economía (VAB provincial a precios de 2004) y proyecciones de población de la DNAP."
    )
  )

# ggsave("outputs/plots/clase3_bump_pbg.png", width = 12, height = 8)


# =============================================================================
# RESPUESTAS
# =============================================================================
# 1. group = provincia porque hay 24 líneas, una por jurisdicción. El color
#    agrupa de a tres (regiones) pero cada línea sigue a UNA provincia en el
#    tiempo. Con group = la_rioja_region habría solo 3 líneas y el ranking no
#    tendría sentido.
#
# 2. Sin scale_y_reverse(), el puesto 1 queda abajo. "Mejorar en el ranking"
#    (ir hacia el 1) se ve como una línea que BAJA, al revés de la intuición.
#    El bump siempre va con el eje Y invertido.
#
# 3. Para "¿dónde está La Rioja?" no es problema: las 18 provincias del Resto
#    país son contexto, no hace falta distinguirlas. Para "¿cuál es la más
#    rica?" sí sería un problema: ahí habría que destacar la de arriba, no La
#    Rioja. Es la lección de la clase 2: la pregunta define qué se destaca.
#
# 4. Un cambio de un puesto entre dos años consecutivos, en una estimación,
#    probablemente sea ruido. En el caption iría algo como: "El PBG provincial
#    es una estimación; cambios de una posición entre años no son significativos".
#    Lo que sí se puede leer es la TENDENCIA de varios años.
#
# -----------------------------------------------------------------------------
# NOTA - las tres novedades respecto de un gráfico de líneas:
#   1. min_rank(desc(...)) dentro de group_by(anio)  -> transformación en datos
#   2. scale_y_reverse()                              -> el 1 arriba
#   3. linewidth por grupo + etiqueta al final        -> figura/fondo
# El resto (aes, geom_line, scale_color_*, theme_monitor, labs) es idéntico a
# src/12_educ.R. Es la misma gramática.
# =============================================================================
