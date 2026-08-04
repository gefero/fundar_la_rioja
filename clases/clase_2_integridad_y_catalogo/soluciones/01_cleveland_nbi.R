# =============================================================================
# CLASE 2 — EJERCICIO 1: SOLUCIÓN
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/13a_nbi_hogares.csv", show_col_types = FALSE)

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

ANIO <- max(df_largo$anio)

# Se agrupa por región Y dimensión: queremos un promedio por cada combinación,
# colapsando solo los 4 trimestres del año.
df_anual <- df_largo %>%
  filter(anio == ANIO) %>%
  group_by(la_rioja_region, dimension) %>%
  summarise(pct = mean(pct, na.rm = TRUE), .groups = "drop")

df_anual   # 3 regiones × 6 dimensiones = 18 filas


# ---- El Cleveland dot plot --------------------------------------------------

df_anual %>%
  filter(dimension != "NBI total") %>%
  ggplot(aes(x = pct,
             y = fct_reorder(dimension, pct),
             color = la_rioja_region)) +
  geom_line(aes(group = dimension), color = FUNDAR_GRILLA, linewidth = 1.2) +
  geom_point(size = 3.5) +
  scale_color_fundar_multi(name = "Región") +
  scale_x_continuous(limits = c(0, NA)) +
  theme_monitor_barras_h() +
  labs(
    title    = "En La Rioja, el hacinamiento explica casi toda la privación",
    subtitle = paste0("% de hogares con cada privación. Promedio de las 4 ondas de ", ANIO, "."),
    x        = "% de hogares",
    y        = NULL,
    caption  = fuente_fundar("Fundar, con base en la EPH (INDEC).")
  )

ggsave("outputs/plots/clase2_nbi_cleveland.png", width = 10, height = 6)


# =============================================================================
# RESPUESTAS
# =============================================================================
#
# 1. ¿Por qué las dimensiones van en el eje Y?
#    Porque son etiquetas de texto largas ("Capacidad de subsistencia"). En el
#    eje X habría que rotarlas 45° o 90° y se vuelven difíciles de leer. Es la
#    recomendación explícita del informe de Argendata (pág. 24): con muchas
#    categorías, o con etiquetas largas, la variable cualitativa va en el eje Y
#    y la magnitud en el X.
#
#    Además, así el ORDEN del eje Y puede codificar información (ordenamos por
#    valor con fct_reorder), que es otra decisión de diseño: el eje deja de ser
#    una lista alfabética arbitraria y pasa a ser un ranking.
#
# 2. ¿Qué privación explica casi todo el NBI de La Rioja?
#    El hacinamiento. Los promedios de 2025 dan:
#
#                        TOT    HAC    VIV    SAN    ESC    SUB
#      Resto país       2,95   1,89   0,13   0,08   0,24   0,66
#      NOA-Resto        3,98   2,26   0,55   0,24   0,20   0,90
#      La Rioja         2,08   1,90   0,13   0,00   0,00   0,05
#
#    El gráfico muestra algo que la serie del total escondía por completo:
#    La Rioja tiene el NBI total MÁS BAJO de las tres, pero su composición es
#    muy distinta. El hacinamiento es prácticamente idéntico al del resto del
#    país (1,90 vs 1,89) — la diferencia en el total viene de que La Rioja casi
#    no registra las otras cuatro privaciones. Dicho de otro modo: el NBI de
#    La Rioja ES hacinamiento (91% del total, contra 64% en el resto del país y
#    57% en el NOA).
#
#    Ese es el hallazgo, y es exactamente el tipo de cosa que aparece cuando se
#    elige la herramienta según la pregunta. La línea de la serie total no podía
#    mostrarlo.
#
# 3. Si en vez de puntos usaras barras agrupadas, ¿qué se perdería?
#    Probalo:
#
#      geom_col(aes(fill = la_rioja_region), position = "dodge")
#
#    Se pierden tres cosas:
#    - La línea gris que conecta los tres puntos de cada dimensión, que es lo
#      que hace VISIBLE la brecha entre regiones sin agregar ningún dato.
#    - Densidad: 18 barras ocupan mucho más espacio que 18 puntos y generan
#      visual cluttering (es el argumento original de Cleveland).
#    - Precisión de lectura: la barra codifica en LONGITUD (desde el cero); el
#      punto, en POSICIÓN sobre una escala común, que es el canal más preciso
#      según Cleveland & McGill. Para comparar valores entre sí —que es lo que
#      queremos acá— el punto gana.
#
#    Contrapunto honesto: la barra tiene una ventaja, y es que su longitud desde
#    el cero es proporcional al valor, cosa que el punto no comunica. Si lo que
#    importara fuera la magnitud absoluta de cada privación y no la comparación
#    entre regiones, la barra sería defendible.
#
# NOTA METODOLÓGICA — por qué promediamos el año:
#    En el último trimestre suelto, La Rioja da 0,00 % en cuatro de las seis
#    dimensiones. La EPH es una muestra, y el aglomerado La Rioja es un dominio
#    chico: para eventos poco frecuentes (viviendas sin baño, chicos de 6 a 12
#    que no asisten), un trimestre no tiene casos suficientes. Promediar las
#    cuatro ondas cuadruplica la muestra efectiva.
#
#    Esto vale para CUALQUIER comunicación de estos indicadores: nunca reportar
#    un nivel de La Rioja a partir de un solo trimestre.
#
#    Y una advertencia honesta: promediar el año MEJORA la estimación pero no la
#    arregla. Aun con las cuatro ondas, "Condiciones sanitarias" y "Escolaridad"
#    siguen dando 0,00 en La Rioja. Eso NO significa que el fenómeno no exista:
#    significa que la EPH no puede medirlo a este nivel de desagregación. Si el
#    gráfico se publica, el caption tiene que decirlo — un 0,00 sin aclaración se
#    lee como "no hay privación", que es una afirmación que estos datos no
#    sostienen. Para esas dimensiones, la fuente adecuada es el Censo.
