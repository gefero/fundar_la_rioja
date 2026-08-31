## Clase 3 - Bloque A: un gráfico desde cero
##
## Este script corre "vacío" sin romper: el andamiaje (librerías) se ejecuta,
## y cada paso trae su código como comentario para que lo escribas y
## descomentes vos. No hay "______" en código ejecutable: lo que falta lo
## escribís entero, a partir de la guía.
##
## Antes de tocar este archivo: elegí un CSV en
## ../../materiales/catalogo_datos.md y anotá acá cuál elegiste y por qué.

library(tidyverse)
source("./style/fundar_monitor_theme.R")

## ============================================================================
## Paso 0 (5') - La pregunta
## ============================================================================
## Escribila en una oración que se pueda contestar con un sí/no o un número.
## Mala: "Graficar la tasa de desocupación."
## Buena: "¿La desocupación de La Rioja está por debajo del NOA desde 2021?"

# CSV elegido: data/inputs_md/____.csv
# Pregunta:    ____

## ============================================================================
## Paso 1 (5') - Mirar el dato antes de graficar
## ============================================================================

# df <- read_csv("./data/inputs_md/____.csv", show_col_types = FALSE)
# glimpse(df)

# TODO: contestá en comentario -
#   ¿Qué identifica una fila (qué columnas, combinadas, no se repiten)?
#   ¿Qué período cubre `fecha`?
#   ¿Hay NA? (df %>% filter(if_any(everything(), is.na)))

## ============================================================================
## Paso 2 (5') - Elegir la marca
## ============================================================================
## Con la tabla de checklist_visualizacion.md §1 ("¿Qué gráfico?"):
#   Operación elegida:  ____   (¿parte de un todo? ¿ranking? ¿brecha? ¿correlación? ¿cambio en el tiempo?)
#   Marca elegida:       ____   (línea, barra, punto, área...)
#   Por qué esa y no otra: ____

## ============================================================================
## Paso 3 (15') - El gráfico, desde una hoja en blanco
## ============================================================================
## Herramientas del proyecto disponibles (todas en style/fundar_monitor_theme.R):
##   theme_monitor() / theme_monitor_barras_h()
##   scale_color_fundar_multi() / scale_fill_fundar_multi()
##   fuente_fundar("...")
##   puntos_etiqueta(df, var_x, var_y, var_grupo)
##
## Si tu CSV trae `fecha` como texto tipo "2007-Q1": convertila con
## lubridate::yq() antes de graficar, para tener el eje X con fechas reales
## en vez de las 72 etiquetas de texto (la trampa de la Clase 2). Si tu CSV es
## de SIPA (03_, 05_, 07_), `fecha` ya es Date.

# df %>%
#   ggplot(aes(x = ____, y = ____, color = ____)) +
#   geom_____() +
#   scale_color_fundar_multi() +
#   theme_monitor()

## ============================================================================
## Paso 4 (10') - Los tres campos de texto
## ============================================================================
## Con checklist_visualizacion.md §3 al lado. La advertencia metodológica sale
## del catálogo de datos, no se inventa.
#   Título    (el hallazgo, afirmado - no el nombre de la variable): ____
#   Subtítulo (unidad, universo, período):                           ____
#   Caption   (fuente + advertencia metodológica del catálogo):      ____

# TODO: agregá al gráfico del Paso 3:
#   labs(title = "____", subtitle = "____", caption = fuente_fundar("____"))

## ============================================================================
## Paso 5 (5') - Guardar y auto-auditar
## ============================================================================
# ggsave("./outputs/plots/clase3_<nombre_pareja>.png", width = 12, height = 7)

## Antes de mostrarlo a la sala, repasá checklist_visualizacion.md §2:
##   ¿el eje Y arranca en cero (o el corte está justificado y marcado)?
##   ¿entre 6 y 8 marcas por eje?
##   ¿el color codifica lo que tiene que codificar (cualitativo = tono, cuantitativo = luminancia)?
