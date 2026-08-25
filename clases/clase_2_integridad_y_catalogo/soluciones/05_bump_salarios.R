# =============================================================================
# CLASE 2 — MATERIAL EXTRA: bump chart (salario promedio SIPA, 24 jurisdicciones)
# -----------------------------------------------------------------------------
# PREGUNTA: en el RANKING de salario promedio del sector privado registrado
#           entre provincias, ¿dónde se ubica La Rioja y cómo cambió esa
#           posición en el tiempo?
#
# Mismo tipo de gráfico que el bump de puestos asalariados, pero con el
# indicador 03 (salario promedio SIPA) en vez del 05 (puestos). El ranking se
# arma sobre el NIVEL (salario promedio), no sobre la variación.
#
# Un punto que vale la pena decir en voz alta: el indicador 03 está en PESOS
# CORRIENTES (ver README, nota del indicador 03) y por eso una serie de
# tiempo de ese salario es engañosa —la inflación aplasta la historia previa,
# como se discutió en el bloque de integridad visual—. Pero un RANKING
# CRUZADO ENTRE PROVINCIAS EN EL MISMO MES no tiene ese problema: la
# inflación afecta a las 24 jurisdicciones por igual dentro de un mismo mes,
# así que el orden relativo es inmune a la distorsión nominal. Es un buen
# ejemplo de que el mismo dato puede ser una mala idea en una forma (serie de
# tiempo en pesos corrientes) y una buena idea en otra (ranking transversal).
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/03_salarios_privados_SIPA.csv",
               show_col_types = FALSE)


# ---- Paso 1: agregar a nivel anual ------------------------------------------
# Igual que en el bump de puestos: 24 líneas mensuales son ilegibles, 24
# líneas anuales se pueden leer.

df_anual <- df %>%
  mutate(anio = lubridate::year(fecha)) %>%
  filter(anio >= 2015, anio <= 2025) %>%           # años completos únicamente
  group_by(jurisdiccion, anio) %>%
  summarise(salario_promedio = mean(salario_promedio), .groups = "drop")


# ---- Paso 2: rankear cada año ------------------------------------------------
# rank 1 = la provincia con mayor salario promedio ESE año. No hace falta
# pasar a índice ni deflactar: como el ranking compara jurisdicciones DENTRO
# del mismo año, la inflación (que es igual para todas) no altera el orden.

df_rank <- df_anual %>%
  group_by(anio) %>%
  mutate(rank = rank(-salario_promedio, ties.method = "first")) %>%
  ungroup()


# ---- Paso 3: separar protagonistas de contexto ------------------------------
# Tres provincias destacadas, no solo una: La Rioja, y dos puntos de
# comparación con trayectorias bien distintas entre sí — Buenos Aires (la
# provincia de referencia por tamaño) y Salta (otra provincia del NOA, para
# comparar "cerca de casa").
#
# Paleta: en vez de tres matices distintos (que es lo que corresponde para
# una variable CUALITATIVA sin orden), usamos UN solo matiz —el verde/teal
# del proyecto— variando en LUMINANCIA. Tiene sentido acá porque, a
# diferencia de "elegí 3 colores para 3 categorías cualquiera", las tres
# provincias SÍ comparten algo ordenable (son las tres "destacadas" sobre un
# fondo de contexto) y un solo matiz con distinta luminancia queda más
# prolijo sobre el fondo beige que mezclar matices. La regla de la clase
# ("matiz para cualitativas, luminancia para todo lo demás") es una guía, no
# un dogma — acá se prioriza la cohesión visual.
# Chequeado con farver::compare_colour (ΔE ~15-16 entre pasos, todos por
# encima del umbral de 10; y bien lejos de FUNDAR_GRILLA, el gris de
# contexto, así que no se confunden con las líneas de fondo).

destacadas <- c(
  "La Rioja"     = "#006666",   # verde más oscuro (máximo énfasis)
  "Buenos Aires" = "#3C9090",   # verde medio
  "Salta"        = "#73BDBD"    # verde más claro
)

df_resto <- df_rank %>% filter(!jurisdiccion %in% names(destacadas))

df_destacadas <- df_rank %>%
  filter(jurisdiccion %in% names(destacadas)) %>%
  mutate(jurisdiccion = factor(jurisdiccion, levels = names(destacadas)))

df_destacadas %>%
  arrange(jurisdiccion, anio) %>% select(jurisdiccion, anio, rank, salario_promedio)
# Tres trayectorias distintas en el mismo ranking:
# - Buenos Aires: estable en el puesto 6-7 durante toda la serie. Ni entre
#   las mejores (las petroleras la superan) ni cerca de las peores.
# - Salta: escala de forma sostenida, del puesto 18 (2015) al 12-13 (2024-25).
# - La Rioja: se mueve entre el 19 y el 22, sin mejorar ni empeorar de forma
#   sostenida — a diferencia de su vecina Salta, que sí gana posiciones.


# ---- El gráfico --------------------------------------------------------------
# Las tres series destacadas van en UNA sola capa con color mapeado por
# aes() (no fijado "a mano" fuera de aes()): es lo que hace falta para que
# ggplot arme la leyenda automáticamente.

ggplot() +
  geom_line(data = df_resto,
            aes(x = anio, y = rank, group = jurisdiccion),
            color = FUNDAR_GRILLA, linewidth = 0.5) +
  geom_point(data = df_resto,
             aes(x = anio, y = rank, group = jurisdiccion),
             color = FUNDAR_GRILLA, size = 1.3) +

  geom_line(data = df_destacadas,
            aes(x = anio, y = rank, color = jurisdiccion,
                linewidth = jurisdiccion, group = jurisdiccion)) +
  geom_point(data = df_destacadas,
             aes(x = anio, y = rank, fill = jurisdiccion, size = jurisdiccion),
             shape = 21, color = "white", stroke = 0.9) +

  geom_text(data = df_destacadas %>% filter(anio == max(anio)),
            aes(x = anio, y = rank, label = paste0(jurisdiccion, " (", rank, "°)"),
                color = jurisdiccion),
            hjust = -0.12, size = 3.3, fontface = "bold", show.legend = FALSE) +

  scale_color_manual(values = destacadas, name = "Jurisdicción destacada") +
  scale_fill_manual(values = destacadas, guide = "none") +
  scale_linewidth_manual(values = c("La Rioja" = 1.3, "Buenos Aires" = 1.1, "Salta" = 1.1),
                         guide = "none") +
  scale_size_manual(values = c("La Rioja" = 3.6, "Buenos Aires" = 3.2, "Salta" = 3.2),
                    guide = "none") +

  scale_y_reverse(breaks = seq(1, 24, by = 2),
                  expand = expansion(mult = c(0.04, 0.04))) +
  scale_x_continuous(breaks = seq(2015, 2025, by = 1),
                     expand = expansion(mult = c(0.02, 0.18))) +
  coord_cartesian(clip = "off") +
  theme_monitor() +
  theme(panel.grid.major.y = element_line(color = FUNDAR_GRILLA, linewidth = 0.3)) +
  labs(
    title    = "Salta escaló en el ranking salarial privado; La Rioja se quedó atrás",
    subtitle = "Ranking de las 24 jurisdicciones por salario promedio del sector privado registrado (SIPA, promedio anual). 1° = salario más alto ese año. Buenos Aires como referencia de escala.",
    x        = NULL,
    y        = "Posición en el ranking (1° = salario más alto)",
    caption  = fuente_fundar("Fundar, con base en el SIPA (Ministerio de Capital Humano). Salarios en pesos corrientes: el nivel de cada año no es comparable entre sí, pero el ranking dentro de cada año sí.")
  )

ggsave("clases/clase_2_integridad_y_catalogo/plots/clase2_bump_salarios.png", width = 15, height = 7)


# =============================================================================
# NOTA METODOLÓGICA
# =============================================================================
# Los tres bump charts posibles con estos datos (crecimiento de empleo, nivel
# de empleo, nivel de salario) cuentan historias distintas de La Rioja:
#   - Por CRECIMIENTO de empleo: volátil, arrancó bien y perdió posiciones.
#   - Por NIVEL de empleo (% del total nacional): casi plano, siempre entre
#     las últimas — la escala económica de una provincia cambia despacio.
#   - Por NIVEL de salario: también predominantemente en las últimas
#     posiciones, pero con más movimiento año a año que el de empleo, porque
#     el salario privado es más sensible a shocks sectoriales (en este caso,
#     el ciclo de las provincias petroleras que empujan el techo del ranking
#     hacia arriba o abajo).
# Ninguna de las tres es "la" respuesta correcta: la pregunta que se elige
# hacer (¿crecimiento? ¿peso? ¿salario?) determina qué historia cuenta el
# ranking.
