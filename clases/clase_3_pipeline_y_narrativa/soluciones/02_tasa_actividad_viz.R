# =============================================================================
# CLASE 3 — PASO 4: SOLUCIÓN
# Destino final: src/06_tasa_actividad.R
# =============================================================================

library(tidyverse)
source("./style/fundar_monitor_theme.R")

df <- read_csv("./data/inputs_md/06_tasa_actividad.csv", show_col_types = FALSE)

df_plot <- df %>%
  mutate(fecha = lubridate::yq(fecha))

df_plot %>%
  ggplot(aes(x = fecha,
             y = tasa_actividad,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  ylim(0, 55) +
  theme_monitor() +
  labs(
    title    = "La Rioja ofrece menos trabajo al mercado que el promedio del país",
    subtitle = "Tasa de actividad: PEA como % de la población total. Aglomerados urbanos, 2007-2025, trimestral.",
    x        = NULL,
    y        = "Tasa de actividad (%)",
    caption  = fuente_fundar(
      "Fundar, con base en la EPH (INDEC). La EPH no relevó entre 2015-T3 y 2016-T1. Estimaciones trimestrales para La Rioja: dominio muestral chico, interpretar la tendencia y no los valores puntuales."
    )
  )

ggsave("./outputs/plots/06_tasa_actividad.png", width = 12, height = 7)


# =============================================================================
# SOBRE EL TÍTULO — la discusión de la puesta en común
# =============================================================================
#
# Los datos, para poder discutirlo con números:
#
#   La Rioja está por debajo del Resto del país en 70 de los 72 trimestres.
#   Está por debajo del NOA en 39 de 72 (o sea: alterna, no hay patrón claro).
#   Rango de la serie de La Rioja: 39,2 % (mínimo) a 48,9 % (máximo, 2025-Q4).
#
# TÍTULO ELEGIDO:
#   "La Rioja ofrece menos trabajo al mercado que el promedio del país"
#   ✔ Afirma un hallazgo, se lee solo, y es robusto: 70 de 72 trimestres.
#   ✔ Traduce "tasa de actividad" a algo interpretable ("ofrece trabajo al
#     mercado"), que es trabajo de comunicación, no de estadística.
#
# TÍTULOS QUE HAY QUE RECHAZAR, y por qué:
#
#   ✘ "Tasa de actividad"
#     Nombra la variable. No dice nada. Es lo que tienen hoy los diez
#     indicadores del repo.
#
#   ✘ "La Rioja alcanzó al resto del país en 2025"
#     Es TENTADOR y es lo que dice el último dato: en 2025-Q4 La Rioja marcó
#     48,9 % contra 48,8 % del resto del país. Pero descansa en UN SOLO
#     TRIMESTRE de un dominio muestral chico, y es además el máximo histórico
#     de la serie — o sea, exactamente el punto donde más probable es que sea
#     ruido. Los tres trimestres previos daban 45,6 / 45,6 / 46,3.
#     Es el error que la advertencia muestral de la clase 2 busca evitar, y
#     conviene mostrarlo en clase porque es el titular que todos querríamos
#     escribir.
#
#   ✘ "La Rioja tiene menos actividad económica que el resto del país"
#     Cambia el significado del indicador. La tasa de ACTIVIDAD mide
#     participación laboral (cuánta gente trabaja o busca trabajo), no
#     actividad económica. Un error de traducción, no de dato.
#
# SOBRE EL CAPTION — las tres preguntas del paso 3:
#
#   ¿Hay que advertir sobre el quiebre 2015/2016?
#     El quiebre de PONDIIO/PONDERA es un problema de INGRESOS: este indicador
#     usa PONDERA, que existe en toda la serie, así que ese quiebre no aplica.
#     Pero SÍ hay que advertir la INTERRUPCIÓN de la EPH entre 2015-T3 y
#     2016-T1: ahí no hay dato, y la línea que cruza el hueco es interpolación
#     visual. Dos problemas distintos que suelen confundirse.
#
#   ¿Hay que advertir sobre el tamaño de muestra?
#     Sí, y va en el caption. Es lo que separa este gráfico de un titular
#     equivocado.
#
#   ¿Se ve el hueco en el gráfico?
#     No: geom_line() une los puntos a ambos lados como si nada. Se puede
#     hacer visible insertando filas con NA en los trimestres faltantes, o
#     marcando el período con un geom_rect() gris. Vale la pena discutirlo:
#     ¿es responsabilidad del gráfico mostrar lo que no se midió?


# =============================================================================
# EXTRA — actividad, empleo y desocupación juntas
# =============================================================================

desoc  <- read_csv("./data/inputs_md/04_tasa_desoc.csv",  show_col_types = FALSE)
empleo <- read_csv("./data/inputs_md/10_tasa_empleo.csv", show_col_types = FALSE)

bind_rows(
  df     %>% transmute(fecha, la_rioja_region, serie = "Actividad",    valor = tasa_actividad),
  empleo %>% transmute(fecha, la_rioja_region, serie = "Empleo",       valor = tasa_empleo),
  desoc  %>% transmute(fecha, la_rioja_region, serie = "Desocupación", valor = tasa_desoc)
) %>%
  filter(la_rioja_region == "3. La Rioja") %>%
  mutate(fecha = lubridate::yq(fecha),
         serie = factor(serie, levels = c("Actividad", "Empleo", "Desocupación"))) %>%
  ggplot(aes(x = fecha, y = valor)) +
  geom_line(color = unname(FUNDAR_MULTI["serie_3"]), linewidth = 0.7) +
  facet_wrap(~ serie, ncol = 1, scales = "free_y") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  theme_monitor() +
  labs(title    = "Actividad, empleo y desocupación en La Rioja",
       subtitle = "Escalas independientes por panel: se comparan las VARIACIONES, no los niveles.",
       x = NULL, y = "%",
       caption  = fuente_fundar("Fundar, con base en la EPH (INDEC)."))

# ¿Está justificado el `scales = "free_y"`?
#   Sí, y es la excepción que el informe de Argendata admite explícitamente
#   (pág. 11 y 15-16): en líneas facetadas donde lo que se compara son
#   variaciones conjuntas y no niveles, se puede trabajar con escalas que no
#   arrancan en cero. Acá es necesario: la desocupación se mueve entre 2% y 12%
#   y la actividad entre 39% y 49%; con escala común, la desocupación sería una
#   línea plana contra el piso.
#
#   La contrapartida es que el lector puede creer que las tres series son
#   comparables en magnitud. Por eso hay que DECIRLO en el subtítulo, como se
#   hace arriba. Esa aclaración no es opcional.
#
#   Y es, además, la alternativa correcta al doble eje: el informe recomienda
#   facetar en vez de superponer dos escalas arbitrarias en un mismo panel.
