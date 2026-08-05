## A quién está dirigido

El taller tiene un público mixto y está diseñado alrededor de esa mezcla:

- **Perfil mantenimiento** — quienes van a mantener este repositorio y actualizar los datos
  cuando salga una onda nueva de la EPH o un reporte nuevo del SIPA.
- **Perfil comunicación** — quienes van a tomar estos indicadores y armar los productos de
  difusión: informes, presentaciones, placas, el dashboard.

> Los CSV de `data/inputs_md/` son la frontera entre los dos equipos. El equipo de datos garantiza
> que estén bien calculados y actualizados. El equipo de comunicación decide cómo se leen. Ese
> contrato es lo que permite que las dos mitades trabajen en paralelo.

Por eso la práctica de las clases 2 y 3 se hace **en parejas de perfiles mezclados**: quien
comunica define la pregunta y redacta el título; quien mantiene escribe el código.

Toda la práctica corre sobre los CSV ya versionados de `data/inputs_md/` — **no hace falta
descargar microdatos** para hacer el taller.

## Antes de la primera clase

1. Instalar R (≥ 4.1) y RStudio.
2. Clonar el repositorio y abrir `fundar_larioja.Rproj` en RStudio.
3. Correr [`materiales/00_setup.R`](./materiales/00_setup.R): instala los paquetes necesarios,
   verifica que los datos estén en su lugar y dibuja un gráfico de prueba.

## Clase 1 — Gramática de gráficos y percepción

Cómo está construido un script de visualización del repo, capa por capa. Marcas, canales y
jerarquía perceptual: por qué un gráfico se entiende o no.

- [Diapositivas — teórica](./clase_1_gramatica_y_percepcion/Clase_1_GoG_percepción.pdf)
- [Práctica — consigna](./clase_1_gramatica_y_percepcion/practica.html)
- [Práctica — notebook (.Rmd)](./clase_1_gramatica_y_percepcion/practica.Rmd)
- Soluciones:
  [Ej. 1 y 3 — respuestas](./clase_1_gramatica_y_percepcion/soluciones/01_y_03_respuestas.md) ·
  [Ej. 2 — mapeos alternativos](./clase_1_gramatica_y_percepcion/soluciones/02_mapeos_alternativos.R)

[⬇ Descargar todo (clase 1, .zip)](./clase_1_gramatica_y_percepcion/clase_1_gramatica_y_percepcion.zip)

## Clase 2 — Integridad visual y catálogo de herramientas

Tufte y el caso Challenger, factor de mentira, el catálogo de herramientas gráficas de Argendata y
cómo elegir la correcta según la pregunta que se busca responder.

- [Práctica — consigna](./clase_2_integridad_y_catalogo/practica.html)
- [Práctica — notebook (.Rmd)](./clase_2_integridad_y_catalogo/practica.Rmd)
- Soluciones:
  [Ej. 1](./clase_2_integridad_y_catalogo/soluciones/01_cleveland_nbi.R) ·
  [Ej. 2](./clase_2_integridad_y_catalogo/soluciones/02_brecha_salarios.R) ·
  [Ej. 3](./clase_2_integridad_y_catalogo/soluciones/03_spaghetti_puestos.R) ·
  [Ej. 4](./clase_2_integridad_y_catalogo/soluciones/04_test_paleta.R)

[⬇ Descargar todo (clase 2, .zip)](./clase_2_integridad_y_catalogo/clase_2_integridad_y_catalogo.zip)

## Clase 3 — Del microdato al producto

El pipeline completo (descarga, limpieza, indicadores, publicación), cómo alinear narrativa y
visualización, y una práctica integradora: agregar un indicador nuevo al monitor de punta a punta.

- [Práctica — consigna](./clase_3_pipeline_y_narrativa/practica.html)
- [Práctica — notebook (.Rmd)](./clase_3_pipeline_y_narrativa/practica.Rmd)
- Soluciones:
  [Ej. 1 — cálculo](./clase_3_pipeline_y_narrativa/soluciones/01_tasa_actividad_calculo.R) ·
  [Ej. 2 — visualización](./clase_3_pipeline_y_narrativa/soluciones/02_tasa_actividad_viz.R) ·
  [Registro en el dashboard](./clase_3_pipeline_y_narrativa/soluciones/03_registro_dashboard.md)

[⬇ Descargar todo (clase 3, .zip)](./clase_3_pipeline_y_narrativa/clase_3_pipeline_y_narrativa.zip)

## Materiales de referencia

- [Checklist de visualización](./materiales/checklist_visualizacion.html) — una página para tener
  al lado mientras se arma un producto de comunicación.
- [Cheatsheet — mantenimiento del repositorio](./materiales/cheatsheet_repo.html) — el mapa del
  repo y los comandos de las tareas frecuentes.
- [`00_setup.R`](./materiales/00_setup.R) — verificación del entorno, para correr antes de la
  primera clase.
- [`paleta_regional_swatch.R`](./materiales/paleta_regional_swatch.R) — genera el swatch de los 3
  colores regionales del monitor, leyendo `FUNDAR_MULTI` desde el tema real.
- [Informe final — evaluación de Argendata](./materiales/Informe_final_argendata.pdf) (Rosati,
  2024) — la fuente del catálogo de herramientas gráficas de la clase 2.
- [Diapositivas — Clase 1: nociones conceptuales e integridad visual](./materiales/deck_clase_1_introduccion.pdf)
  (169 diapositivas; las clases 1 y 2 usan distintos bloques de este mismo deck).

---

Materiales del **Componente 3** de un proyecto con el Gobierno de La Rioja. Repositorio completo
en [github.com/gefero/fundar_la_rioja](https://github.com/gefero/fundar_la_rioja).
