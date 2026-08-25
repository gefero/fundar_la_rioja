# =============================================================================
# CLASE 2 — EJERCICIO 1: de la línea al Cleveland dot plot
# -----------------------------------------------------------------------------
# PREGUNTA: ¿qué privación explica el NBI de La Rioja, y en qué se diferencia
#           del NOA y del resto del país?
#
# Es una comparación de BRECHAS ENTRE UNIDADES en un CORTE TRANSVERSAL.
# Según la taxonomía del informe de Argendata: Cleveland dot plot.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/13a_nbi_hogares.csv", show_col_types = FALSE)


# ---- PASO 1: formato largo --------------------------------------------------
# Las 6 dimensiones están en 6 columnas. Las apilamos.

df_largo <- df %>%
  select(fecha, la_rioja_region, starts_with("pct_hogares_NBI_")) %>%
  pivot_longer(starts_with("pct_hogares_NBI_"),
               names_to = "dimension", values_to = "pct") %>%
  mutate(
    anio      = as.integer(str_sub(fecha, 1, 4)),
    dimension = str_remove(dimension, "pct_hogares_NBI_"),
    dimension = recode(dimension,
                       TOT = "NBI total",
                       HAC = "Hacinamiento",
                       VIV = "Vivienda inconveniente",
                       SAN = "Condiciones sanitarias",
                       ESC = "Escolaridad",
                       SUB = "Capacidad de subsistencia")
  )


# ---- PASO 2: promediar las 4 ondas del último año ---------------------------
# ⚠️ ESTO NO ES UN DETALLE.
# Corré esto para ver por qué:

df_largo %>%
  filter(fecha == max(fecha), la_rioja_region == "3. La Rioja") %>%
  select(dimension, pct)

# En un trimestre suelto, La Rioja da 0,00 % en cuatro de las seis dimensiones.
# No es que no haya privación: es que la muestra de un dominio chico no alcanza
# para estimarla. Promediar las cuatro ondas del año estabiliza la estimación.

ANIO <- max(df_largo$anio)

# TODO: completá el group_by() y el summarise() para promediar las 4 ondas
#       del año ANIO, por región y dimensión.

df_anual <- df_largo %>%
  filter(anio == ANIO) %>%
  group_by(______, ______) %>%           # <-- TODO: ¿por qué dos variables agrupan?
  summarise(pct = mean(pct, na.rm = TRUE), .groups = "drop")

df_anual   # deberían ser 3 regiones × 6 dimensiones = 18 filas


# ---- PASO 3: el Cleveland dot plot ------------------------------------------
# Dimensiones en el eje Y, porcentaje en el X, un punto por región.
#
# TODO 1: las dimensiones tienen que quedar ORDENADAS POR VALOR, no
#         alfabéticamente. Pista: fct_reorder(dimension, pct).
# TODO 2: el color mapea a la región, y usamos la escala del proyecto.

df_anual %>%
  filter(dimension != "NBI total") %>%   # el total no compite con sus partes
  ggplot(aes(x = pct,
             y = ______,                 # <-- TODO 1
             color = ______)) +          # <-- TODO 2
  # La línea gris conecta los tres puntos de cada dimensión: hace visible la
  # BRECHA entre regiones sin agregar ningún dato nuevo.
  geom_line(aes(group = dimension), color = FUNDAR_GRILLA, linewidth = 1.2) +
  geom_point(size = 3.5) +
  scale_color_fundar_multi(name = "Región") +
  scale_x_continuous(limits = c(0, NA)) +   # el eje arranca en cero
  theme_monitor_barras_h() +                # variante con grilla vertical
  labs(
    title    = "TODO: escribilo vos — que AFIRME el hallazgo, no que nombre la variable",
    subtitle = paste0("% de hogares con cada privación. Promedio de las 4 ondas de ", ANIO, "."),
    x        = "% de hogares",
    y        = NULL,
    caption  = fuente_fundar("Fundar, con base en la EPH (INDEC).")
  )

# ggsave("clases/clase_2_integridad_y_catalogo/plots/clase2_nbi_cleveland.png", width = 10, height = 6)


# =============================================================================
# PREGUNTAS
# =============================================================================
# 1. ¿Por qué las dimensiones van en el eje Y y no en el X?
#    (Pista: son etiquetas de texto largas, y hay 5.)
#
# 2. Con el gráfico terminado: ¿qué privación explica casi todo el NBI de
#    La Rioja?
#
# 3. Si en vez de puntos usaras barras agrupadas, ¿qué se perdería?
#    Probalo: cambiá geom_point() por geom_col(position = "dodge").
