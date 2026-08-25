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


# ---- Paso 3: separar protagonista de contexto -------------------------------

df_resto    <- df_rank %>% filter(jurisdiccion != "La Rioja")
df_la_rioja <- df_rank %>% filter(jurisdiccion == "La Rioja")

df_la_rioja %>% arrange(anio) %>% select(anio, rank, salario_promedio)
# La Rioja se mueve entre el puesto 19 y el 22 de 24 a lo largo de la serie:
# consistentemente entre las de menor salario privado promedio, con algo más
# de movimiento que en el ranking por participación en el empleo (que era
# casi plano). Las provincias con salarios más altos y más volátiles en el
# ranking son las petroleras/mineras (Neuquén, Santa Cruz, Chubut, Tierra del
# Fuego), que suben y bajan con el ciclo de esos sectores.


# ---- El gráfico --------------------------------------------------------------

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
  scale_x_continuous(breaks = seq(2015, 2025, by = 1),
                     expand = expansion(mult = c(0.02, 0.16))) +
  coord_cartesian(clip = "off") +
  theme_monitor() +
  theme(panel.grid.major.y = element_line(color = FUNDAR_GRILLA, linewidth = 0.3)) +
  labs(
    title    = "El salario privado de La Rioja está sistemáticamente entre los más bajos del país",
    subtitle = "Ranking de las 24 jurisdicciones por salario promedio del sector privado registrado (SIPA, promedio anual). 1° = salario más alto ese año.",
    x        = NULL,
    y        = "Posición en el ranking (1° = salario más alto)",
    caption  = fuente_fundar("Fundar, con base en el SIPA (Ministerio de Capital Humano). Salarios en pesos corrientes: el nivel de cada año no es comparable entre sí, pero el ranking dentro de cada año sí.")
  )

ggsave("outputs/plots/clase2_bump_salarios.png", width = 15, height = 7)


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
