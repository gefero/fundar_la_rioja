# Práctica — Clase 2

**Duración:** 40 minutos.

**Se hace en parejas de perfiles mezclados.** Quien comunica define la pregunta que el gráfico tiene
que responder y redacta el título; quien mantiene escribe el código. Los dos roles son necesarios:
un gráfico técnicamente impecable que responde a la pregunta equivocada no sirve para nada.

**Cómo repartirlo:** cada pareja elige **uno** de los tres primeros ejercicios (30'). El ejercicio 4
lo hacemos entre todos al final (10'), porque el resultado es una decisión de proyecto.

Todos trabajan sobre `data/inputs_md/`. Soluciones completas en `soluciones/`.

---

## Ejercicio 1 — De la línea al Cleveland dot plot (NBI)

**Archivo:** `ejercicios/01_cleveland_nbi.R` · **Dificultad:** guiado

`src/13a_nbi_hogares.R` grafica hoy **una sola línea por región**, con el NBI **total**. Las cinco
sub-dimensiones —hacinamiento, vivienda, sanitarias, escolaridad, subsistencia— están calculadas en
el CSV y **no se muestran en ningún lado**.

La pregunta que el gráfico actual no puede contestar es justamente la más interesante:

> **¿Qué privación explica el NBI de La Rioja, y en qué se diferencia del NOA y del resto del país?**

Eso es una comparación de **brechas entre unidades en un corte transversal**. Según la taxonomía:
**Cleveland dot plot**.

Lo que hay que hacer:

1. Pasar el CSV a formato largo (una fila por dimensión).
2. **Promediar las cuatro ondas del último año.** ⚠️ Esto no es un detalle: en un trimestre suelto,
   La Rioja da **0,00 % en cuatro de las seis dimensiones**. No es que no haya privación — es que la
   muestra de un dominio chico no alcanza. Promediar el año estabiliza la estimación.
3. Dimensiones en el eje Y (**ordenadas por valor**, no alfabéticamente), porcentaje en el X, un
   punto de color por región.

**Preguntas para responder:**

- ¿Por qué las dimensiones van en el eje Y y no en el X?
- Con el gráfico terminado: ¿qué privación explica casi todo el NBI de La Rioja?
- Si en vez de puntos usaras barras agrupadas, ¿qué se perdería?

---

## Ejercicio 2 — La brecha implícita (salarios público/privado)

**Archivo:** `ejercicios/02_brecha_salarios.R` · **Dificultad:** medio

`src/03b_salarios_registrados_EPH.R` grafica dos líneas por región (público y privado), facetadas.
Se ve bien, pero la pregunta que importa es sobre la **distancia entre las dos**:

> **¿Se agrandó o se achicó la brecha salarial entre el sector público y el privado en La Rioja?**

La recomendación del informe de Argendata (págs. 19–20) es **no** graficar la brecha calculada como
una tercera serie, sino dejar que **el área entre las dos líneas la muestre sola**. Se percibe de
forma preatentiva y no agrega elementos al gráfico.

Lo que hay que hacer:

1. Filtrar La Rioja y pasar a formato ancho (una columna por sector).
2. `geom_ribbon()` entre las dos series, con el color según quién está arriba.
3. Encima, las dos líneas.
4. Marcar el quiebre metodológico de 2015/2016 con una línea punteada, y **decirlo en el caption**.

**Preguntas:**

- ¿Por qué hay que marcar el quiebre? (Pista: `README.md`, sección del indicador 03b.)
- Compará tu gráfico con `outputs/plots/03b_salarios_registrados_EPH.png`. ¿Qué gana y qué pierde
  cada versión?
- El eje Y está en **pesos corrientes**. Mirando la slide 159 del deck: ¿qué le agregarías al
  gráfico antes de publicarlo?

---

## Ejercicio 3 — Spaghetti plot (24 jurisdicciones)

**Archivo:** `ejercicios/03_spaghetti_puestos.R` · **Dificultad:** abierto

`data/inputs_md/05_puestos_asalariados_privados.csv` tiene los puestos asalariados privados de las
**24 jurisdicciones**, mensual desde 2009. `src/05_puestos_asalariados_privados.R` lo grafica
facetado por región.

> **¿Cómo le fue al empleo privado en La Rioja comparado con el resto del país?**

Son 24 categorías y ~200 instancias temporales. Según la taxonomía: **spaghetti plot** — una línea
por unidad, la protagonista destacada, el resto en gris de contexto.

Hay un problema previo: **los niveles no son comparables**. Buenos Aires tiene 1.750 mil puestos y
La Rioja unas decenas. En un mismo eje, todas las provincias chicas quedan aplastadas contra el
cero. La solución del informe (pág. 16): **índice base 100** en el primer período.

Lo que hay que hacer:

1. Convertir cada serie a índice base 100 en su primer valor.
2. Dibujar las 24 en gris claro, y **La Rioja encima** en el color de énfasis.
3. Etiquetar La Rioja en el extremo derecho (nada de leyenda con 24 entradas).

**Preguntas:**

- ¿Por qué La Rioja tiene que dibujarse **después** de las demás? (Pista: es el mismo problema que
  resuelven los prefijos `1.`/`2.`/`3.` de `la_rioja_region`.)
- Al pasar a índice base 100, ¿qué información **perdiste**?
- Comparalo con el gráfico actual. ¿Cuál usarías para un informe y cuál para un anexo?

---

## Ejercicio 4 — Auditar nuestra propia paleta (todos juntos, 10')

**Archivo:** `ejercicios/04_test_paleta.R`

`FUNDAR_MULTI` (`style/fundar_monitor_theme.R:25`) se eligió por criterio estético, replicando el
Monitor Mensual de Empresas. **Nunca se auditó** con los criterios que vimos hoy. Vamos a hacerlo.

> Nota: `src/test_escalas.R` es un intento a medio hacer de exactamente esto. Carga las paletas de
> ColorBrewer y ahí queda. Este ejercicio lo completa.

Tres tests:

1. **Contraste de luminancia** — ¿La Rioja se distingue de las otras dos series?
2. **Distancia perceptual (ΔE2000)** — ¿los tres colores son suficientemente distintos entre sí?
   Regla práctica: ΔE < 10 es riesgoso para series superpuestas.
3. **Daltonismo** — simular deuteranopia y protanopia con `colorspace` y volver a mirar.

**La discusión final es una decisión de proyecto**, no un ejercicio: con los números a la vista,
¿mantenemos la paleta, la ajustamos, o agregamos un canal redundante (grosor de línea) para no
depender solo del color?

---

## Puesta en común (10')

Cada pareja muestra su gráfico en 2 minutos y responde **una** pregunta:

> **¿Qué se ve ahora que no se veía antes?**
