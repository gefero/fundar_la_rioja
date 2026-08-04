# Práctica — Clase 1

**Duración:** 40 minutos.

Antes de empezar: abrí `fundar_larioja.Rproj` en RStudio. Todas las rutas de los scripts son
relativas a la raíz del repo, y el `.Rproj` es lo que la fija.

Los tres ejercicios trabajan sobre los CSV de `data/inputs_md/`, que ya están en el repositorio. **No
hace falta descargar microdatos.**

Si te trabás, las soluciones completas están en `soluciones/`. Miralas después de intentarlo.

---

## Ejercicio 1 — La gramática, capa por capa (15')

**Archivo:** `ejercicios/01_gramatica_capas.R`

Vamos a reconstruir el gráfico de la tasa de desocupación (`src/04_desoc.R`) desde cero, agregando
**una capa por vez** y ejecutando en cada paso.

La consigna es simple pero importante: **ejecutá cada bloque y mirá el gráfico antes de pasar al
siguiente.** El objetivo no es llegar al gráfico final —ya existe— sino ver qué aporta exactamente
cada línea.

Los pasos:

1. Solo los datos y los ejes (`ggplot(aes(...))`, sin geometría). ¿Qué se ve?
2. Agregar `geom_line()`. Va a salir mal. **¿Por qué?**
3. Arreglarlo con `group`.
4. Agregar `color`. ¿Qué cambió respecto del paso 3?
5. Agregar la escala de color del proyecto.
6. Agregar el tema.
7. Agregar títulos y fuente.

**Preguntas para responder mientras lo hacés:**

- En el paso 2, ¿por qué ggplot dibuja una sola línea que va y viene? ¿Qué le falta saber?
- En el paso 4, `color = la_rioja_region` va **dentro** de `aes()` y `linewidth = 0.7` va **fuera**.
  ¿Cuál es la regla?
- En el paso 6, ¿el tema cambió algún dato?

---

## Ejercicio 2 — Tres mapeos del mismo dato (15')

**Archivo:** `ejercicios/02_mapeos_alternativos.R`

`data/inputs_md/13a_nbi_hogares.csv` tiene, para cada trimestre y cada región, el porcentaje de
hogares con NBI **total** y también las **cinco sub-dimensiones**: hacinamiento (`HAC`), vivienda
inconveniente (`VIV`), condiciones sanitarias (`SAN`), escolaridad (`ESC`) y capacidad de
subsistencia (`SUB`).

Hoy `src/13a_nbi_hogares.R` grafica **solo el total**, con una línea por región. Las cinco
sub-dimensiones están calculadas y no se muestran en ningún lado.

Tenés tres versiones del mismo dato para completar:

- **Versión A** — color = dimensión, un panel por región.
- **Versión B** — color = región, un panel por dimensión.
- **Versión C** — todo superpuesto en un solo panel: color = región, tipo de línea = dimensión.

**La consigna no es "cuál es la más linda", es "a qué pregunta responde mejor cada una".** Anotá,
para cada versión, una pregunta que se conteste bien mirándola:

| Versión | ¿Qué pregunta contesta bien? | ¿Qué pregunta contesta mal? |
|---|---|---|
| A | | |
| B | | |
| C | | |

Pistas de discusión:

- ¿Cuál sirve para "¿qué privación pesa más en La Rioja?"
- ¿Cuál sirve para "¿La Rioja está mejor o peor que el NOA en hacinamiento?"
- La versión C usa **dos canales a la vez** (matiz y tipo de línea) sobre la misma marca. Mirando la
  slide 37 del deck, ¿son separables? ¿Cuántas series terminás viendo?

---

## Ejercicio 3 — Romper el gráfico a propósito (10')

**Archivo:** `ejercicios/03_romper_canales.R`

Este ejercicio es para **comprobar en carne propia** la jerarquía de canales que vimos en la teoría.

Tomá el gráfico de la tasa de empleo (`data/inputs_md/10_tasa_empleo.csv`) y hacé tres versiones
donde la región se codifique con canales distintos:

- **A** — con `color` (el canal que usa el repo).
- **B** — con `shape` (forma del punto).
- **C** — con `size` (grosor de línea).

Después, para cada una, contestá lo más honestamente posible:

1. ¿Cuánto tardás en encontrar la serie de **La Rioja**?
2. Si dos series se cruzan, ¿podés seguirlas?
3. ¿Podrías distinguir seis series en vez de tres con ese canal?

**Bonus (2'):** en la versión A, cambiá la paleta del proyecto por una donde las tres regiones tengan
la **misma luminancia** (el script trae una preparada). La Rioja deja de saltar a la vista. Ese es,
exactamente, el efecto que la paleta del proyecto está diseñada para producir.

---

## Puesta en común (10')

Traé a la puesta en común:

- Del ejercicio 2: tu tabla de "qué pregunta contesta cada versión".
- Del ejercicio 3: en cuál de las tres versiones tardaste más en encontrar La Rioja.
