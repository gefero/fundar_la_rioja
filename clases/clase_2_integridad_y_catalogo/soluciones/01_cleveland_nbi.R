# =============================================================================
# CLASE 2 — EJERCICIO 1: SOLUCIÓN
# -----------------------------------------------------------------------------
# Versión actualizada: en vez de comparar las 6 sub-dimensiones del NBI en un
# único corte transversal, comparamos el NBI AGREGADO (total, todas las
# privaciones juntas) en dos momentos del tiempo — el primer y el último año
# completo disponibles en la EPH — para las 3 regiones.
#
# No se puede hacer por PROVINCIA: la EPH no tiene cobertura representativa a
# nivel provincial (es una encuesta por aglomerados urbanos), por eso el
# pipeline solo agrega a 3 regiones. Un NBI por provincia requeriría datos de
# Censo, que hoy no están en este repo.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/13a_nbi_hogares.csv", show_col_types = FALSE)


# ---- Paso 1: primer y último año completo de la EPH -------------------------
# La serie va de 2007-Q1 a 2025-Q4: 2007 es el primer año con las 4 ondas, 2025
# el último. Igual que en la versión anterior, promediamos las 4 ondas de cada
# año para estabilizar la estimación (dominio chico, ver nota metodológica).

df <- df %>% mutate(anio = as.integer(str_sub(fecha, 1, 4)))

ANIO_INI <- min(df$anio)
ANIO_FIN <- max(df$anio)

df_dos_anios <- df %>%
  filter(anio %in% c(ANIO_INI, ANIO_FIN)) %>%
  group_by(la_rioja_region, anio) %>%
  summarise(pct = mean(pct_hogares_NBI_TOT, na.rm = TRUE), .groups = "drop")

df_dos_anios   # 3 regiones × 2 años = 6 filas


# ---- Paso 2: a formato ancho para el segmento -------------------------------
# geom_segment necesita el punto de inicio y de fin EN LA MISMA FILA.

df_ancho <- df_dos_anios %>%
  pivot_wider(names_from = anio, values_from = pct, names_prefix = "pct_")

df_ancho


# ---- Paso 3: fijar el orden del eje Y UNA sola vez ---------------------------
# ⚠️ Ojo con este error común: si llamamos fct_reorder() por separado en cada
# capa (una vez con los datos de ANIO_INI, otra con los de ANIO_FIN), cada
# llamada puede devolver un orden distinto —2007 y 2025 no rankean igual las
# regiones— y el eje queda inconsistente entre capas. Por eso fijamos el
# orden una sola vez, sobre el valor más reciente, y lo aplicamos como factor
# a los dos data frames antes de graficar.

orden_regiones <- df_ancho %>%
  arrange(.data[[paste0("pct_", ANIO_FIN)]]) %>%
  pull(la_rioja_region)

df_dos_anios <- df_dos_anios %>% mutate(la_rioja_region = factor(la_rioja_region, levels = orden_regiones))
df_ancho     <- df_ancho     %>% mutate(la_rioja_region = factor(la_rioja_region, levels = orden_regiones))


# ---- El dumbbell (Cleveland con dos puntos en el tiempo) --------------------
# Región en el eje Y (ordenada por el valor más reciente), % de hogares con
# NBI en el eje X. Un segmento por región conecta el valor inicial con el
# final; el color codifica el AÑO, no la región (acá solo hay 3 categorías en
# el eje Y, ya identificadas por la etiqueta — no hace falta un color por
# región además).
#
# Paleta: mismo criterio que el bump chart de salarios (05_bump_salarios.R) —
# un solo matiz (el verde/teal del proyecto) variando en LUMINANCIA en vez de
# dos matices distintos, y los mismos dos tonos extremos de esa rampa para
# que ambos gráficos de la clase compartan un lenguaje visual. Para que
# aparezca la leyenda, el año va mapeado por aes(color = ...) en una sola
# capa de puntos, no fijado "a mano" por fuera de aes() en dos capas.

colores_anio <- setNames(c("#73BDBD", "#006666"), c(ANIO_INI, ANIO_FIN))

ggplot() +
  geom_segment(data = df_ancho,
               aes(x = !!sym(paste0("pct_", ANIO_INI)),
                   xend = !!sym(paste0("pct_", ANIO_FIN)),
                   y = la_rioja_region, yend = la_rioja_region),
               color = FUNDAR_GRILLA, linewidth = 2) +
  geom_point(data = df_dos_anios,
             aes(x = pct, y = la_rioja_region, color = factor(anio)),
             size = 4) +
  scale_color_manual(values = colores_anio, name = NULL) +
  scale_x_continuous(limits = c(0, NA)) +
  theme_monitor_barras_h() +
  labs(
    title    = "La Rioja tenía un NBI intermedio en 2007 y hoy es el más bajo de las tres regiones",
    subtitle = paste0("% de hogares con Necesidades Básicas Insatisfechas (NBI total). ",
                      "Promedio de las 4 ondas de ", ANIO_INI, " y de ", ANIO_FIN, "."),
    x        = "% de hogares con NBI",
    y        = NULL,
    caption  = fuente_fundar("Fundar, con base en la EPH (INDEC).")
  )

ggsave("clases/clase_2_integridad_y_catalogo/plots/clase2_nbi_cleveland.png", width = 13, height = 6)


# =============================================================================
# RESPUESTAS
# =============================================================================
#
# 1. ¿Por qué las regiones van en el eje Y?
#    Mismo argumento que en la versión anterior: son pocas categorías (3) pero
#    con etiquetas de texto, y el orden del eje codifica información (acá, el
#    nivel de NBI en el año más reciente) en vez de ser alfabético.
#
# 2. ¿Qué muestra el gráfico que la serie de tiempo (una línea por región)
#    no muestra tan bien?
#    El CAMBIO DE ORDEN. En 2007 La Rioja tenía un NBI INTERMEDIO (10,2%):
#    por encima de Resto país (7,3%) pero por debajo de NOA-Resto (12,5%).
#    Para 2025 pasó a tener el NBI más bajo de las tres (2,1%, por debajo
#    incluso de Resto país). Una serie de tiempo con las tres líneas también
#    mostraría esto, pero el dumbbell lo hace de un vistazo: no hace falta
#    seguir 19 años de trimestres para ver que el orden cambió.
#
#    Los números:
#                      2007    2025   var. (p.p.)
#      Resto país       7,3     3,0      -4,3
#      NOA-Resto       12,5     4,0      -8,5
#      La Rioja        10,2     2,1      -8,1
#
#    Las tres regiones bajaron su NBI en el período, pero La Rioja y el NOA
#    bajaron mucho más (en puntos porcentuales) que el Resto país — que ya
#    arrancaba más bajo y tenía menos margen para caer.
#
# 3. ¿Por qué no partir el NBI en sus 6 sub-dimensiones acá también?
#    Se podría (es lo que hacía la versión anterior de este ejercicio, para UN
#    solo año), pero cruzar 6 dimensiones × 3 regiones × 2 años en el mismo
#    panel satura el gráfico. Con dos preguntas distintas conviene separar en
#    dos gráficos: éste (el agregado cambió, ¿cuánto y en qué orden?) y uno
#    de composición para un año dado (¿qué privación explica el total?, que
#    es la pregunta de la versión anterior — queda como variante posible).
#
# NOTA METODOLÓGICA — por qué promediamos cada año:
#    Igual que antes: un trimestre suelto tiene poca muestra efectiva en un
#    dominio chico como La Rioja. Promediar las 4 ondas de 2007 y las 4 de
#    2025 estabiliza ambas puntas de la comparación.
