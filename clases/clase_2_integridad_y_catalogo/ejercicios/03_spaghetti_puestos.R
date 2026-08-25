# =============================================================================
# CLASE 2 — EJERCICIO 3: spaghetti plot
# -----------------------------------------------------------------------------
# PREGUNTA: ¿cómo le fue al empleo privado en La Rioja comparado con el resto
#           del país?
#
# 24 jurisdicciones × ~205 meses. Según la taxonomía: SPAGHETTI PLOT — una línea
# por unidad, la protagonista destacada, el resto en gris de contexto.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/05_puestos_asalariados_privados.csv",
               show_col_types = FALSE)

glimpse(df)   # jurisdiccion, fecha, puestos_miles


# ---- El problema previo: los niveles no son comparables ----------------------
# Corré esto y mirá la diferencia de escala:

df %>%
  filter(fecha == min(fecha)) %>%
  arrange(desc(puestos_miles)) %>%
  slice(c(1:3, 22:24))

# Buenos Aires arranca en ~1.750 mil puestos y La Rioja en ~27 mil. En un mismo
# eje, todas las provincias chicas quedan aplastadas contra el cero.
#
# La solución del informe de Argendata (pág. 16): ÍNDICE BASE 100 en el primer
# período. Deja de comparar niveles y pasa a comparar TRAYECTORIAS.


# ---- PASO 1: índice base 100 ------------------------------------------------
# TODO: completá el group_by() y el cálculo del índice.
#       El índice de cada provincia es su valor dividido por SU PROPIO primer
#       valor, por 100.

df_idx <- df %>%
  arrange(jurisdiccion, fecha) %>%
  group_by(______) %>%                                   # <-- TODO
  mutate(indice = puestos_miles / ______ * 100) %>%      # <-- TODO (pista: first())
  ungroup()

# Verificación: todas las provincias deberían valer 100 en el primer mes.
df_idx %>% filter(fecha == min(fecha)) %>% count(indice)


# ---- PASO 2: separar la protagonista del contexto ---------------------------
# El truco del spaghetti: DOS dataframes, no uno. El de contexto se dibuja
# primero (queda abajo) y el protagonista después (queda encima).

df_resto    <- df_idx %>% filter(jurisdiccion != "La Rioja")
df_la_rioja <- df_idx %>% filter(jurisdiccion == "La Rioja")


# ---- PASO 3: el gráfico -----------------------------------------------------
# TODO: completá el orden de las capas. ¿Cuál va primero?

ggplot() +

  # Capa de contexto: las 23 jurisdicciones restantes, en gris claro.
  # `group` es imprescindible: sin él, ggplot une todas las provincias en una
  # sola línea (mismo problema que vimos en la clase 1).
  geom_line(data = ______,                    # <-- TODO
            aes(x = fecha, y = indice, group = jurisdiccion),
            color = FUNDAR_GRILLA, linewidth = 0.4) +

  # Capa protagonista: La Rioja, en el color de énfasis.
  geom_line(data = ______,                    # <-- TODO
            aes(x = fecha, y = indice),
            color = unname(FUNDAR_MULTI["serie_3"]), linewidth = 1.1) +

  # Referencia: el nivel de partida.
  geom_hline(yintercept = 100, linetype = "dotted",
             color = FUNDAR_GRIS, linewidth = 0.4) +

  # Etiqueta en el extremo derecho, en vez de una leyenda con 24 entradas.
  geom_text(data = df_la_rioja %>% filter(fecha == max(fecha)),
            aes(x = fecha, y = indice, label = "La Rioja"),
            hjust = -0.15, size = 3.2, fontface = "bold",
            color = unname(FUNDAR_MULTI["serie_3"])) +

  scale_x_date(date_labels = "%Y", date_breaks = "2 years",
               expand = expansion(mult = c(0.02, 0.10))) +
  coord_cartesian(clip = "off") +
  theme_monitor() +
  labs(
    title    = "TODO: escribilo vos — ¿le fue mejor o peor que al resto?",
    subtitle = paste0("Puestos asalariados privados registrados. Índice base 100 = ",
                      format(min(df$fecha), "%b-%Y"),
                      ". Cada línea gris es una jurisdicción."),
    x        = NULL,
    y        = "Índice (base 100)",
    caption  = fuente_fundar("Fundar, con base en el SIPA (Ministerio de Capital Humano).")
  )

# ggsave("clases/clase_2_integridad_y_catalogo/plots/clase2_spaghetti_puestos.png", width = 11, height = 6)


# =============================================================================
# PREGUNTAS
# =============================================================================
# 1. ¿Por qué La Rioja tiene que dibujarse DESPUÉS de las demás?
#    (Pista: es el mismo problema que resuelven los prefijos "1."/"2."/"3."
#     de la_rioja_region en src/utils_eph.R.)
#
# 2. Al pasar a índice base 100, ¿qué información PERDISTE?
#    ¿Cómo la recuperarías sin romper el gráfico?
#
# 3. Compará con outputs/plots/05_puestos_asalariados_privados.png (el actual,
#    facetado por región). ¿Cuál usarías para un informe y cuál para un anexo?
#
# 4. EXTRA: el índice base 100 depende del mes elegido como base. Probá con
#    otro (por ejemplo, enero de 2016) y mirá si la conclusión cambia.
#    ¿Qué te dice eso sobre cómo comunicar este gráfico?
