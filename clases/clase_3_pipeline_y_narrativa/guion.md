# Clase 3 - Un gráfico desde cero y de dónde salen los datos

**Duración:** 120 minutos. **100% práctica: sin diapositivas.** Material de apoyo:
[`materiales/catalogo_datos.md`](../materiales/catalogo_datos.md),
[`materiales/checklist_visualizacion.md`](../materiales/checklist_visualizacion.md) y
[`materiales/cheatsheet_repo.md`](../materiales/cheatsheet_repo.md), impresos o abiertos al lado.

**Objetivo de la clase:** cerrar el circuito con dos operaciones, no con una teórica. Las clases 1
y 2 dieron el vocabulario (marcas, canales, integridad, catálogo de herramientas); esta clase lo
pone a producir: armar un gráfico entero por cuenta propia, y entender de dónde sale el dato que
ese gráfico dibuja.

Sigue siendo la clase donde los dos perfiles hacen cosas distintas pero acopladas - eso no cambió.
Lo que cambia es que ya no hay un bloque teórico separado por perfil: **los dos bloques son
prácticos y los dos perfiles trabajan juntos en cada uno.**

---

## 0-10' · Arranque

1. Abrir `fundar_larioja.Rproj` en RStudio (fija el working directory en la raíz del repo).
2. Correr `clases/materiales/00_setup.R` si alguien no lo hizo antes de venir.
3. Proyectar (o repartir impreso) `materiales/catalogo_datos.md`. Es el único material nuevo de
   esta clase - reemplaza a las diapositivas.
4. Armar parejas de perfiles mezclados, igual que en la Clase 2.

**No hay que explicar el pipeline acá.** Se explica solo, en el Bloque B, a partir de lo que cada
pareja encuentra. Resistí la tentación de adelantar el diagrama - es más fuerte cuando lo
reconstruyen ellos.

---

## 10-55' · Bloque A - Un gráfico desde cero (45')

Consigna completa en [`practica.md`](practica.md) §Bloque A. Cada pareja:

1. Elige un CSV del catálogo (**no** el que ya usaron en la Clase 1 o 2) y escribe una pregunta en
   una oración.
2. Mira el dato antes de graficar.
3. Elige la marca con la tabla de `checklist_visualizacion.md` §1.
4. Escribe el `ggplot()` desde cero, en `ejercicios/01_grafico_desde_cero.R`.
5. Escribe los tres campos de texto (título afirmado, subtítulo, caption con la advertencia
   metodológica **que trae el catálogo**, no inventada).
6. Guarda el PNG y se auto-audita con `checklist_visualizacion.md` §2.

### Cómo circular

- El momento en que más se traban es el Paso 0 (elegir pregunta y CSV) y el Paso 3 (la hoja en
  blanco). Para el Paso 0: si a los 5' una pareja no arrancó, señalales directamente una fila del
  catálogo y la pregunta sugerida - no hace falta que la inventen si el bloqueo es ahí.
- Para el Paso 3: recordá que tienen las herramientas del proyecto ya armadas
  (`theme_monitor()`, `scale_color_fundar_multi()`, `fuente_fundar()`) - no arrancan de un
  `ggplot()` sin nada, arrancan sin el gráfico ya resuelto. Si se quedan mirando la pantalla,
  preguntales primero qué eligieron en el Paso 2 (la marca): de ahí sale el primer `geom_`.
- **No corrijas el título en el momento.** Anotalo para la puesta en común - es más rico
  compararlo con los de las otras parejas que corregirlo en el momento.
- `soluciones/01_ejemplos_resueltos.R` tiene tres ejemplos completos (barras horizontales,
  scatter, small multiples), sobre tres CSV y tres marcas que las Clases 1 y 2 no usaron. Sirven de
  referencia si una pareja se traba en serio, no como "la" solución - la consigna es de elección
  libre a propósito.

---

## 55-65' · Puesta en común del Bloque A (10')

Cada pareja proyecta su PNG 60 segundos: qué pregunta eligieron, qué marca, y el título. **El
título es el foco de la puesta en común** - comparar cómo distintas parejas resolvieron "afirmar el
hallazgo, no nombrar la variable" sobre datos distintos deja el punto mucho más claro que una tabla
de ejemplos.

---

## 65-70' · Pausa

---

## 70-105' · Bloque B - De dónde salió esa columna (35')

Consigna completa en [`practica.md`](practica.md) §Bloque B. Trabajan sobre el **mismo CSV** que
usaron en el Bloque A. Sin descargar microdatos, sin red: `ejercicios/02_rastreo_pipeline.R` trae
las preguntas del rastreo (B1), el espacio para dibujar el diagrama a mano (B2) y los chunks de
auditoría (B3).

### Cómo circular

- La herramienta es **Ctrl+Shift+F** (Find in Files) de RStudio, buscando el nombre del CSV y de
  sus columnas dentro de `src/`. Si nadie la conoce, hacé una demo de 1 minuto al arrancar el
  bloque - ahorra mucho tiempo después.
- Hay dos caminos según el CSV elegido (EPH o SIPA), y **un caso especial**: quien haya elegido
  `07_serie_empresas_por_jurisdiccion.csv` va a llegar a un final abierto - ese CSV no tiene script
  de prep en el repo. Es un hallazgo real, no un error de esa pareja: si les toca, decíselos así y
  dejá que lo documenten como tal. `soluciones/02_rastreo_respuestas.md` lo explica en detalle.
- El paso B2 (dibujar el diagrama en papel) es el que reemplaza a la vieja diapositiva del pipeline
  - la diferencia es que ahora lo reconstruyen ellos a partir de lo que encontraron, no lo reciben
  hecho. Dejá tiempo para que efectivamente dibujen, no solo lo digan.
- La auditoría B3 es el momento más concreto del bloque: correr tres líneas y ver que la diferencia
  da ~1e-13. Para quien haya elegido un CSV de SIPA (sin numerador/denominador propio) la auditoría
  es de estructura (`count(...) %>% filter(n > 1)`), no de recálculo - aclaraselos si preguntan por
  qué su chunk es distinto al de la pareja de al lado.

### Las tres trampas (para vos, no para proyectar)

Van a aparecer solas como respuesta a las preguntas de cierre del rastreo, pero tenelas presentes
para reforzarlas si una pareja no llega:

1. **La descarga incremental no re-descarga.** Si agregás una variable a `vars_individuo`, los
   `.rds` que ya existen **no** se actualizan: el paso saltea archivos existentes. Hay que
   **borrarlos** y volver a correr `00`. Es la causa nº 1 de "agregué la variable y me viene todo
   `NA`".
2. **El orden de `as.character()` en `limpiar_base_eph()`.** Al revés, `as.character()` devuelve el
   **código** en vez de la etiqueta, y todas las comparaciones de texto dejan de matchear **en
   silencio, sin error ni warning**. Es el bug más difícil de detectar del pipeline.
3. **El quiebre 2015/2016.** `PONDIIO` no existe antes de ~2016, y la EPH estuvo interrumpida entre
   2015-T3 y 2016-T1. Se ve en que `13a_`/`13b_` tienen 71 trimestres en vez de 72.

---

## 105-120' · Cierre

### El mapa de pendientes del repositorio

Cerrar el taller con trabajo real. Estos son los pendientes concretos, y conviene salir con nombres
asignados:

**Indicadores sin implementar** (marcados "Pendiente" en el README):

- Cantidad de empleados públicos cada 1.000 hab.
- Tasa de pobreza multidimensional · Trayectoria escolar
- PIB provincial · % del PIB que es industrial · Exportaciones
- Resultado fiscal · Recursos propios sobre recursos totales

**Deuda técnica identificada durante el taller:**

- **El indicador 03 está en pesos corrientes** (Clase 2). Requiere sumar una serie de IPC al
  repositorio para deflactar. Es el pendiente de mayor impacto sobre la calidad de lo publicado.
- **`07_serie_empresas_por_jurisdiccion.csv` no tiene script de prep documentado** (si salió en el
  Bloque B de esta clase). Hay que reconstruir de dónde sale y escribir el script que falta.
- **Los títulos nombran variables en vez de afirmar hallazgos**, en los diez `labs()` originales
  del repo (los de las parejas, hechos en esta clase, ya no tienen ese problema).
- **La auditoría de la paleta** (Clase 2) quedó con una recomendación pendiente de decidir e
  implementar.
- **El markdown que ejecuta los scripts y arma el informe** todavía no existe (lo pide `CLAUDE.md`).

### Las tres ideas del taller

1. **Un gráfico es un mapeo de datos a propiedades visuales**, y los canales no son
   intercambiables. (Clase 1)
2. **La pregunta define la herramienta**, y un gráfico claro igual puede mentir. (Clase 2)
3. **El circuito es reproducible de punta a punta**, y se puede reconstruir leyendo el código: el
   CSV es el contrato entre los dos equipos, y todo lo que hay antes de esa frontera se puede
   rastrear sin adivinar nada. (Clase 3)
