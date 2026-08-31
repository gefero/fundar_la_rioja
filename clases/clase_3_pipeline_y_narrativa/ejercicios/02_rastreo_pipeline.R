## Clase 3 - Bloque B: de dónde salió esa columna
##
## Trabajás sobre el MISMO CSV que elegiste en el Bloque A. Sin descargar
## microdatos, sin red: la herramienta es Ctrl+Shift+F (Find in Files) de
## RStudio, buscando el nombre del archivo CSV y el de sus columnas en src/.
##
## Si te trabás, las respuestas completas están en
## ../soluciones/02_rastreo_respuestas.md - pero contestá primero, aunque sea
## a medias: el ejercicio es el rastreo, no la respuesta.

library(tidyverse)

## ============================================================================
## B1 - El rastreo (15')
## ============================================================================
## Camino EPH (tu CSV es 04_, 09a_, 10_, 12_, 13a_, 13b_ o 03b_):
##
##   1. ¿Qué script escribió este CSV? (buscá el nombre del archivo en src/)
##      Respuesta: ____
##
##   2. Ese script lee un .rds con read_rds(). ¿Cuál, y qué script lo escribió?
##      Respuesta: ____
##
##   3. ¿En qué línea de ESE script se creó la variable que se está sumando o
##      promediando en tu CSV (ej. `ocupado`, `desocupado`, `NBI_HAC`)?
##      Respuesta: ____
##
##   4. Esa variable derivada depende de una columna cruda de la EPH
##      (ej. ESTADO, IV1, IV8). ¿Dónde se pidió esa columna por primera vez?
##      Respuesta: ____
##
##   5. ¿Qué función convirtió el código numérico de esa columna cruda
##      (ej. "1") en el texto legible (ej. "Ocupado"), y por qué importa el
##      ORDEN en que se aplica esa función respecto de sacar la clase "labelled"?
##      Respuesta: ____
##
## Camino SIPA (tu CSV es 03_, 05_ o 07_):
##
##   1. ¿Hay un script que prep-ó este CSV? Si lo hay, ¿de qué archivo .xlsx
##      crudo? Si NO lo hay (buscá bien: el script que LEE el CSV no es lo
##      mismo que el que lo ESCRIBE), esa ausencia es en sí misma un hallazgo
##      del rastreo - documentalo.
##      Respuesta: ____
##
##   2. (si hay prep) ¿Qué transformación de formato necesitó ese .xlsx antes
##      de poder pivotear a formato largo (fila = fecha × provincia)?
##      Respuesta: ____
##
##   3. (si hay prep) ¿Dónde se homologan los nombres de provincia entre la
##      fuente y el resto del proyecto, y por qué hace falta ese paso?
##      Respuesta: ____

## ============================================================================
## B2 - Dibujar el diagrama (10')
## ============================================================================
## En papel, a partir de lo que encontraste en B1: las etapas del pipeline
## (cuántas hay, qué archivo produce cada una) y dónde cae la línea de lo que
## está versionado en git. Comparalo con el de referencia al cierre.

## ============================================================================
## B3 - Auditar el CSV sin microdatos (10')
## ============================================================================
## Los CSV de tasas EPH traen las columnas de conteo además de la tasa
## calculada, así que el cálculo se puede reproducir sin volver a bajar nada.
##
## Si tu CSV es 04_, 09a_, 10_, 12_, 13a_ o 13b_ (trae numerador y
## denominador): elegí el bloque que corresponda y corré la verificación.

# Ejemplo con 04_tasa_desoc.csv (adaptá nombres de columna a tu CSV):
# read_csv("./data/inputs_md/04_tasa_desoc.csv", show_col_types = FALSE) %>%
#   mutate(control = desoc / pea * 100) %>%
#   summarise(dif_maxima = max(abs(tasa_desoc - control)))
# → tiene que dar un número minúsculo (error de redondeo, no un problema del cálculo).

## Si tu CSV es 03_, 03b_, 05_ o 07_ (no trae numerador/denominador, porque es
## una serie SIPA o un promedio ponderado): no se puede recalcular sin las
## fuentes crudas. En su lugar, auditá la ESTRUCTURA:

# read_csv("./data/inputs_md/____.csv", show_col_types = FALSE) %>%
#   count(jurisdiccion, fecha) %>%      # o la_rioja_region/sector si es 03b_
#   filter(n > 1)
# → tiene que devolver 0 filas: ninguna combinación de unidad-período repetida.

## Preguntas para cerrar el bloque:
##   ¿Por qué data/inputs_md/ está versionado en git y data/raw_data/ no?
##   Sale una onda nueva de la EPH: ¿qué corrés, y qué NO volvés a correr?
##   ¿Y si además agregaste una variable nueva a vars_individuo? (pista: no alcanza
##   con sumarla al vector - ver la trampa nº 1 en soluciones/02_rastreo_respuestas.md)
