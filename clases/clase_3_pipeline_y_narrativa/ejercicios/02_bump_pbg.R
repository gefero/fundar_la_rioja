# =============================================================================
# CLASE 3 - BLOQUE A, PARTE 2: bump chart (ranking del PBG per cápita)
# -----------------------------------------------------------------------------
# Versión simplificada de src/15_pbg_ranking_percapita.R.
#
# PREGUNTA: ¿en qué puesto está La Rioja en el ranking provincial de PBG per
#           cápita, y cómo cambió ese puesto entre 2010 y 2024?
#
# La gramática es LA MISMA que la de un gráfico de líneas. Un bump chart es un
# gráfico de líneas con tres cosas de más:
#   1. una transformación en el paso de datos: de VALOR a RANKING
#   2. scale_y_reverse(): el puesto 1 va arriba
#   3. el patrón figura/fondo: contexto en gris, La Rioja destacada
#
# Corré desde la raíz del repo, de a un bloque por vez con Ctrl+Enter.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

prov <- read_csv(
  "data/inputs_md/15_pbg_per_capita_por_provincia.csv",
  show_col_types = FALSE
)

glimpse(prov)
# anio             : 2010 .. 2024
# provincia        : las 24 jurisdicciones
# pbg_per_capita   : PBG per cápita en pesos constantes de 2004
# la_rioja_region  : "1. Resto país" / "2. NOA-Resto" / "3. La Rioja"
#                    (ya viene en el CSV: lo usamos para el patrón figura/fondo)


# ---- Paso 1: de valor a ranking -----------------------------------------
# NOVEDAD 1. El gráfico NO va a dibujar pbg_per_capita, va a dibujar el puesto
# en el ranking de cada año. Este es el concepto central: muchas veces el
# gráfico grafica algo DERIVADO de la columna del CSV, no la columna cruda.
#
# TODO 1: dentro del group_by(anio), calculá `ranking` con
#         min_rank(desc(pbg_per_capita))  -> 1 = el PBG per cápita más alto.

rank_df <- prov %>%
  group_by(anio) %>%
  mutate(ranking = ______) %>%                          # <-- TODO 1
  ungroup() %>%
  # La Rioja (factor nivel "3.") se ordena última -> se dibuja ENCIMA del resto.
  arrange(la_rioja_region, provincia, anio)

# Chequeo: en cada año tiene que haber los puestos 1 a 24, sin repetir.
rank_df %>% count(anio) %>% pull(n) %>% unique()        # -> 24
rank_df %>% filter(provincia == "La Rioja") %>% select(anio, ranking)


# ---- Paso 2: el gráfico crudo ------------------------------------------
# Mismo aes que un gráfico de líneas: x = tiempo, y = ranking, una línea por
# provincia, color por región. Mirá los dos problemas: el puesto 1 está abajo,
# y las tres regiones pesan visualmente igual.

ggplot(rank_df, aes(x = anio, y = ranking,
                    group = provincia, color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.6) +
  scale_color_fundar_multi(name = "Región") +
  theme_monitor()


# ---- Paso 3: dar vuelta el eje Y y aplicar figura/fondo ---------------
# NOVEDAD 2. scale_y_reverse(): el puesto 1 arriba.
# NOVEDAD 3. figura/fondo por grosor de línea: el contexto ("1. Resto país" y
#            "2. NOA-Resto") fino, La Rioja gruesa. El color ya lo da la
#            paleta; el grosor refuerza.
#
# TODO 2: agregá scale_y_reverse(breaks = 1:24).
# TODO 3: en scale_linewidth_manual(), poné tres valores crecientes (uno por
#         nivel de la_rioja_region, en orden): contexto fino, La Rioja gruesa.
#         P. ej. c(0.3, 0.5, 1.4).

ggplot(rank_df, aes(x = anio, y = ranking, group = provincia,
                    color = la_rioja_region)) +
  geom_line(aes(linewidth = la_rioja_region)) +
  ______ +                                              # <-- TODO 2: scale_y_reverse(...)
  scale_color_fundar_multi(name = "Región") +
  scale_linewidth_manual(values = ______, guide = "none") +   # <-- TODO 3
  scale_x_continuous(breaks = seq(2010, 2024, 2)) +
  theme_monitor()


# ---- Paso 4: la etiqueta de La Rioja, en vez de leyenda ---------------
# NOVEDAD 3 (cont.). Una etiqueta al final de la línea de La Rioja se lee
# mejor que buscarla en la leyenda. Necesita coord_cartesian(clip = "off")
# y un margen a la derecha para que el texto no se corte.
#
# TODO 4: completá el data = del geom_text para quedarte SOLO con la fila de
#         La Rioja en el último año (anio == max(anio) y provincia == "La Rioja").

etiqueta_lr <- rank_df %>%
  filter(______)                                        # <-- TODO 4

ggplot(rank_df, aes(x = anio, y = ranking, group = provincia,
                    color = la_rioja_region)) +
  geom_line(aes(linewidth = la_rioja_region)) +
  geom_text(
    data = etiqueta_lr,
    aes(label = paste0("La Rioja (", ranking, "°)")),
    hjust = -0.1, size = 3.2, fontface = "bold", show.legend = FALSE
  ) +
  scale_y_reverse(breaks = 1:24) +
  scale_color_fundar_multi(name = "Región") +
  scale_linewidth_manual(values = c(0.3, 0.5, 1.4), guide = "none") +
  scale_x_continuous(breaks = seq(2010, 2024, 2),
                     expand = expansion(mult = c(0.02, 0.15))) +
  coord_cartesian(clip = "off") +
  theme_monitor() +
  theme(plot.margin = margin(16, 80, 16, 16)) +
  labs(
    title    = "______",   # el hallazgo: ¿La Rioja subió, bajó o se mantuvo?
    subtitle = "Puesto entre las 24 jurisdicciones · PBG per cápita en pesos constantes de 2004",
    x = NULL, y = "Puesto (1 = mayor PBG per cápita)",
    caption  = fuente_fundar("Fundar, con base en CEPAL / Ministerio de Economía y proyecciones de población de la DNAP.")
  )

# ggsave("outputs/plots/clase3_bump_pbg.png", width = 12, height = 8)


# =============================================================================
# PREGUNTAS
# =============================================================================
# 1. ¿Por qué group = provincia y no group = la_rioja_region? (Pista: ¿cuántas
#    líneas hay dibujadas?)
#
# 2. Sacá scale_y_reverse(). ¿Qué le pasa a la lectura de "subir en el ranking"?
#
# 3. Con color = la_rioja_region no se distinguen entre sí las 18 provincias
#    del "Resto país". ¿Es un problema para ESTA pregunta? ¿Y si la pregunta
#    fuera "¿cuál es la provincia más rica del país"?
#
# 4. El PBG provincial es una estimación. Si La Rioja pasa del puesto 20 al 19
#    entre dos años, ¿es una tendencia o puede ser ruido? ¿Qué escribirías en
#    el caption al respecto?
