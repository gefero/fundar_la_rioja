# =============================================================================
# CLASE 2 — MATERIAL EXTRA: bump chart (24 jurisdicciones)
# -----------------------------------------------------------------------------
# PREGUNTA: en el RANKING de peso del empleo privado entre provincias, ¿dónde
#           se ubica La Rioja y cómo cambió esa posición en el tiempo?
#
# El ejercicio 3 (spaghetti) ya muestra la TRAYECTORIA de CRECIMIENTO de cada
# provincia (índice base 100). Este bump chart mide otra cosa: no cuánto
# creció cada provincia, sino qué % del empleo privado del país representa
# cada una, año a año, y cómo se ordenan entre sí. Según la taxonomía del
# informe de Argendata: bump chart — "evolución de rankings, no de niveles
# absolutos" — pero acá el ranking se arma sobre el NIVEL (participación %),
# no sobre la tasa de variación.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/05_puestos_asalariados_privados.csv",
               show_col_types = FALSE)


# ---- Paso 1: agregar a nivel anual ------------------------------------------
# Un bump chart mensual con 24 líneas × ~200 meses es ilegible. Agregamos a
# promedio anual: 24 líneas × 17 años es un ranking que se puede leer.

df_anual <- df %>%
  mutate(anio = lubridate::year(fecha)) %>%
  filter(anio >= 2009, anio <= 2025) %>%           # años completos únicamente
  group_by(jurisdiccion, anio) %>%
  summarise(puestos_miles = mean(puestos_miles), .groups = "drop")


# ---- Paso 2: % del empleo privado nacional -----------------------------------
# A diferencia del ejercicio 3 (índice base 100, que mide CRECIMIENTO), acá
# rankeamos por NIVEL: cuánto pesa cada provincia sobre el total nacional de
# puestos privados, cada año.

df_pct <- df_anual %>%
  group_by(anio) %>%
  mutate(pct_nacional = puestos_miles / sum(puestos_miles) * 100) %>%
  ungroup()


# ---- Paso 3: rankear cada año ------------------------------------------------
# rank 1 = la provincia con mayor participación en el empleo privado ESE año.

df_rank <- df_pct %>%
  group_by(anio) %>%
  mutate(rank = rank(-pct_nacional, ties.method = "first")) %>%
  ungroup()


# ---- Paso 4: separar protagonista de contexto (igual que el spaghetti) -----

df_resto    <- df_rank %>% filter(jurisdiccion != "La Rioja")
df_la_rioja <- df_rank %>% filter(jurisdiccion == "La Rioja")

df_la_rioja %>% arrange(anio) %>% select(anio, rank, pct_nacional)
# La Rioja se mueve apenas entre el puesto 22 y el 23 de 24 en los 17 años:
# a diferencia del ranking por CRECIMIENTO (mucho más volátil), el ranking
# por NIVEL es casi plano. Tiene sentido: el peso relativo de cada provincia
# en el empleo privado nacional es una variable estructural que cambia muy
# lento, incluso si el crecimiento interanual es volátil.


# ---- El gráfico --------------------------------------------------------------
# Capas: contexto gris primero, La Rioja destacada encima (mismo truco que el
# spaghetti). El eje Y se invierte: rank 1 arriba.

ggplot() +
  geom_line(data = df_resto,
            aes(x = anio, y = rank, group = jurisdiccion),
            color = FUNDAR_GRILLA, linewidth = 0.5) +
  geom_point(data = df_resto,
             aes(x = anio, y = rank, group = jurisdiccion),
             color = FUNDAR_GRILLA, size = 1.3) +

  geom_line(data = df_la_rioja,
            aes(x = anio, y = rank),
            color = unname(FUNDAR_MULTI["serie_3"]), linewidth = 1.3) +
  geom_point(data = df_la_rioja,
             aes(x = anio, y = rank),
             color = unname(FUNDAR_MULTI["serie_3"]), size = 2.8) +

  geom_text(data = df_la_rioja %>% filter(anio == max(anio)),
            aes(x = anio, y = rank, label = paste0("La Rioja (", rank, "°)")),
            hjust = -0.12, size = 3.4, fontface = "bold",
            color = unname(FUNDAR_MULTI["serie_3"])) +

  scale_y_reverse(breaks = seq(1, 24, by = 2),
                  expand = expansion(mult = c(0.04, 0.04))) +
  scale_x_continuous(breaks = seq(2009, 2025, by = 2),
                     expand = expansion(mult = c(0.02, 0.16))) +
  coord_cartesian(clip = "off") +
  theme_monitor() +
  theme(panel.grid.major.y = element_line(color = FUNDAR_GRILLA, linewidth = 0.3)) +
  labs(
    title    = "El peso de La Rioja en el empleo privado nacional es chico y prácticamente estable",
    subtitle = "Ranking de las 24 jurisdicciones por % del empleo privado nacional (promedio anual de puestos asalariados privados). 1° = mayor participación ese año.",
    x        = NULL,
    y        = "Posición en el ranking (1° = mayor participación)",
    caption  = fuente_fundar("Fundar, con base en el SIPA (Ministerio de Capital Humano).")
  )

ggsave("outputs/plots/clase2_bump_puestos.png", width = 15, height = 7)


# =============================================================================
# NOTA METODOLÓGICA
# =============================================================================
# El bump chart y el spaghetti (ejercicio 3) parten del MISMO dataset, pero
# rankean cosas distintas:
#   - Spaghetti: trayectoria de CRECIMIENTO (índice base 100).
#   - Bump:      ranking de NIVEL (% de participación en el total nacional).
#
# Una provincia puede tener un índice de crecimiento muy volátil (como se ve
# en el spaghetti) y aun así casi no moverse en el ranking por nivel, porque
# su participación en el total nacional es chica y la escala relativa entre
# provincias grandes y chicas cambia muy despacio. Es exactamente lo que
# pasa acá: el ranking por nivel es mucho menos interesante que el ranking
# por crecimiento — y esa diferencia ES el punto pedagógico: la pregunta que
# se elige (¿cuánto pesa? vs. ¿cuánto creció?) determina si el bump chart
# muestra movimiento o una foto casi fija.
