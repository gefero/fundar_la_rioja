# Clase 2 — Integridad visual y catálogo de herramientas

**Duración:** 120 minutos · **Teoría:** 65' · **Práctica:** 45' · **Cierre:** 10'

**Material de slides:**
- Primera mitad: `clases/materiales/Copia de Pract_Clase_1_introducción.pdf`, **diapositivas 58 a 169**
  (el bloque "Integridad Visual"), recortado —ver abajo qué se saca—.
- Segunda mitad: **slides nuevas**, a partir de
  [`clases/materiales/Informe_final_argendata.pdf`](../materiales/Informe_final_argendata.pdf).

**Objetivo de la clase:** que al terminar, cualquiera de los dos perfiles pueda (a) detectar cuándo
un gráfico distorsiona los datos, y (b) elegir la herramienta gráfica adecuada a partir de la
pregunta, en vez de por costumbre.

---

## 0–5' · Repaso

De la clase 1 quedaron tres cosas, que conviene recuperar en una slide antes de seguir:

1. Todo gráfico es un mapeo de datos a propiedades visuales.
2. Los canales no son intercambiables: posición > longitud > área > ángulo > forma.
3. Lo que comparte panel es lo que se compara bien, porque comparte escala.

La clase 1 fue sobre si un gráfico **se entiende**. Esta es sobre si además **dice la verdad**, y
sobre cómo elegir la herramienta.

---

## 5–40' · Integridad visual

**Slides:** 58–169 del deck, recortadas. **Slides nuevas a hacer: 2** (el caso del repo, ver abajo).

Es mucho material para 35 minutos. El recorte sugerido, en cuatro bloques:

### a) El caso Challenger (15') — slides 59–111

Es el caso más potente del deck y hay que darlo, pero **acelerado**: son 50 diapositivas y la mayor
parte son *builds* progresivos de la misma imagen. Se pasan rápido y se para solo en los hitos:

- **59–63** — El accidente: 28 de enero de 1986, falla en las juntas tóricas, temperatura de −6 °C.
  Los ingenieros habían dado el alerta y recomendaron no despegar en 13 gráficas. La NASA lo
  desestimó: *"la evidencia presentada no es concluyente"*.
- **65** — El problema básico, que es el corazón del caso: **falta de capacidad para demostrar la
  conexión entre las bajas temperaturas y los problemas en las juntas.** No faltaban datos: faltaba
  mostrar la relación.
- **66–86** — El análisis forense del informe: título críptico (SRM sin explicar), sin nombres —y
  los nombres dan credibilidad—, nomenclaturas inconsistentes, fechas escritas a mano, indicadores
  de daño sin definir, y sobre todo: **los cuadros no ordenan por temperatura**. Un solo caso no es
  evidencia; los motores también fallaron a temperaturas normales.
- **87** — La frase para dejar en el pizarrón:

  > **Las relaciones son la evidencia.** Las cifras constituyen evidencia cuando mostramos sus
  > relaciones.

- **88–96** — El rediseño de Tufte: ordenar por temperatura, y la correlación daño-temperatura
  aparece sola. La temperatura del 28/01/1986 queda muy fuera del rango de toda la experiencia
  previa.
- **97** — La conclusión general: *existen mejores y peores maneras de mostrar datos; algunos
  gráficos revelan la verdad y otros la ocultan.*
- **98–111** — El informe oficial de investigación posterior (que también falla): leyenda
  desordenada, *visual clutter* de 48 contornos de cohetes, causa y efecto poco claros, variable de
  ordenamiento equivocada.

**Si hay que recortar más:** las slides 112–122 (John Snow, la marcha de Napoleón, el gráfico
climático) son excelentes pero prescindibles. Se pueden dejar como material de lectura.

### b) El factor de mentira (8') — slides 125–138

Definición de distorsión de Tufte (126):

> Un gráfico está distorsionado si la **representación visual** que presenta no se condice con la
> **representación numérica**.

Y su medida:

```
factor de mentira = proporción en el gráfico ÷ proporción en los datos
```

= 1 está bien; > 1,05 sobrestima; < 0,95 subestima. El ejemplo del estándar de consumo (134–137)
llega a **14,8**: el dato varía 53 % y el dibujo, 783 %.

El *dilema de percepción* (127–129) es el puente hacia la práctica: no podemos hacer una
visualización por lector. Lo mejor que podemos hacer es **generar uniformidad** en nuestros
gráficos. Eso es exactamente lo que hace `style/fundar_monitor_theme.R` en este proyecto.

### c) Variación en los datos, no en el diseño (7') — slides 143–152

Cuando el gráfico cambia de escala, de unidades o de dimensiones a lo largo de sí mismo, el lector
lee variación que no está en los datos. La regla:

> **Debemos visualizar la variación en los datos, no en el diseño.**

Sumar de acá: **dimensionalidad** (160–162) — *la dimensión de los datos no puede ser superada por
la dimensión del gráfico*, que es la razón de fondo por la que no se usa 3D — y **contexto**
(163–167) — *los gráficos no deben sacar los datos de contexto*.

### d) Nominal vs. real (5') — slides 153–159

Playfair, deuda nacional. La regla:

> **En las series de tiempo monetarias, casi siempre es mejor usar unidades estandarizadas en lugar
> de nominales.**

---

### Los dos anclajes en el repo (lo importante de este bloque)

Acá el taller se vuelve incómodo a propósito: los dos ejemplos de violación de integridad los
sacamos de **nuestro propio monitor**, no de un libro. **Slides nuevas: 2.**

**1. Nuestro indicador 03 está en pesos corrientes.**

Abrir `outputs/plots/03_salarios_privados_SIPA.png` y el README, que lo dice sin vueltas: *"en pesos
corrientes la historia previa queda aplastada por la inflación"*, y por eso el prep recorta la serie
desde 2015. Es exactamente la slide 159 aplicada a nosotros: **una serie de salarios en pesos
corrientes en Argentina muestra sobre todo inflación**, no la evolución del poder adquisitivo. La
curva que sube no dice lo que un lector desprevenido va a entender que dice.

El punto pedagógico no es fustigar el repo: es que **este tipo de problema no se ve desde adentro**.
Se cuela por la vía de "el dato viene así de la fuente". Queda anotado como pendiente concreto para
la clase 3.

**2. Nuestros ejes X tienen 72 marcas de texto.**

Abrir `outputs/plots/04_desoc.png`. Los CSV de EPH tienen **72 trimestres**, `fecha` es un string, y
los scripts los dibujan como categorías rotadas 45°. Es *visual cluttering* de manual —el informe de
Argendata recomienda 6 a 8 marcas por eje— y lo tenemos en casi todos los gráficos de la serie EPH.
Se arregla con dos líneas (`lubridate::yq()` + `scale_x_date()`), como se vio en el bloque EXTRA del
ejercicio 1 de la clase 1.

---

## 40–45' · Pausa

---

## 45–70' · El catálogo de herramientas gráficas

**Slides:** todas nuevas. **Slides nuevas a hacer: ~10.** Fuente:
[`Informe_final_argendata.pdf`](../materiales/Informe_final_argendata.pdf), págs. 11–27.

### La idea que ordena el bloque

> Toda visualización tiene por detrás una **tarea analítica**. No todas las representaciones son
> igualmente aptas para todas las tareas.

Tres preguntas antes de elegir el gráfico: **¿qué pregunta querés responder?**, **¿qué tipo de datos
tenés?**, **¿qué operación estás haciendo sobre ellos?**

### La taxonomía (slide de referencia, la más útil de la clase)

Reproducir como tabla —conviene que quede también impresa, está en
[`checklist_visualizacion.md`](../materiales/checklist_visualizacion.md):

| Operación | Corte transversal | Serie de tiempo |
|---|---|---|
| Parte de un todo | waffle · treemap (anidado) | waffle facetado · slope |
| Rankear unidades | barras horizontales ordenadas | slope (2 momentos) · bump (muchos) |
| Mostrar brechas | Cleveland dot plot | líneas con brecha implícita |
| Correlacionar | scatter | líneas facetadas (**nunca doble eje**) |
| Cambios en el tiempo | — | ≤5: slope · 5–50: línea · >50: área · muchas categorías: spaghetti |

### Las herramientas, una por una (una slide cada una, con ejemplo)

- **Small multiples / facetado** — la respuesta por defecto al *cluttering*. Mismos ejes y escalas,
  un panel por categoría. Ya lo usamos en `03b` y `05`.
- **Cleveland dot plot** — alternativa a las barras cuando hay muchas categorías: ocupa menos
  espacio y permite comparación precisa (posición sobre escala común, el mejor canal). Sirve además
  para mostrar **brechas** entre dos series en paralelo.
- **Brecha implícita** — dos líneas y el área entre ellas. Mejor que graficar la brecha calculada:
  se ve de forma preatentiva, sin sumar un elemento al gráfico. Ejemplo del informe: informalidad
  por género, donde el área se achica sola a lo largo del tiempo.
- **Slope chart** — comparar muchas categorías entre dos momentos. Usa el mejor canal (posición
  sobre escala común), por eso captura variaciones chicas mejor que un waffle.
- **Spaghetti plot** — muchas categorías, 8 a 100 instancias temporales, una destacada y el resto en
  gris de contexto.
- **Bump chart** — evolución de *rankings*, no de niveles.
- **Waffle chart** — parte de un todo. Mejor que la torta: los estudios perceptuales muestran
  errores significativamente menores (la torta codifica en ángulo, que es de los peores canales).
- **Barras horizontales ordenadas** — ranking, una variable, un momento. Ordenar por la variable, no
  alfabéticamente.

Dos advertencias del informe que conviene destacar:

- **Nunca doble eje.** Las escalas de un doble eje son arbitrarias y pueden fabricar correlaciones
  que no existen. Alternativa: facetar por variable, o pasar ambas a índice base 100.
- **Ejes desde cero**, con una sola excepción: líneas facetadas donde lo que se compara son
  variaciones relativas, no niveles.

### Paletas de color (los últimos 10' del bloque)

Del informe, págs. 25–34:

- El color son **tres sub-canales**: luminancia (qué tan brillante), saturación (qué tan colorido) y
  matiz/*hue* (lo que llamamos "color"). Luminancia y saturación tienen **ordinalidad implícita**;
  el matiz no.
- De ahí la regla: **matiz para variables cualitativas; luminancia/saturación para ordinales y
  cuantitativas.** Escalas secuenciales (un solo sentido) o divergentes (dos sentidos desde un punto
  medio).
- Entre **6 y 12 colores** discriminables como máximo. Si hacen falta más: agrupar categorías, o
  combinar sub-canales (el informe muestra el caso ENGHo: matiz para agrupar clases de consumo,
  saturación para distinguir dentro de cada clase).
- **Uniformidad perceptual**: si pasos iguales en los datos no producen pasos iguales en el color,
  el gráfico **inventa cortes que no están en los datos** (Quinan et al., 2019) y a la vez
  **esconde variaciones reales**. Es una violación directa del primer principio de Tufte.
  Las ilustraciones de la Mona Lisa y la cartografía sintética (informe, págs. 33–34) lo muestran de
  un golpe: *jet* fabrica bordes que no existen.
- **Daltonismo**: viridis y plasma cumplen; muchas paletas institucionales no.

**El anclaje en el repo:** nuestra paleta `FUNDAR_MULTI` nunca se auditó con estos criterios. Eso es
el ejercicio 4 de la práctica, y `src/test_escalas.R` es un intento a medio hacer de exactamente
esto (carga las paletas de ColorBrewer y ahí queda).

---

## 70–110' · Práctica

Consignas completas en [`practica.md`](practica.md).

**En parejas de perfiles mezclados:** quien comunica define la pregunta y redacta el título; quien
mantiene escribe el código. **Slides nuevas: 1** (consignas).

| Ejercicio | Qué se hace |
|---|---|
| `01_cleveland_nbi.R` | NBI: de una línea de total a un Cleveland dot plot de las 6 dimensiones |
| `02_brecha_salarios.R` | Salarios público/privado: brecha implícita con `geom_ribbon()` |
| `03_spaghetti_puestos.R` | 24 jurisdicciones: spaghetti en índice base 100 |
| `04_test_paleta.R` | Auditar `FUNDAR_MULTI`: ΔE y simulación de daltonismo |

**Cómo repartirlo.** No alcanza el tiempo para hacer los cuatro. Sugerencia: **cada pareja elige uno
de los tres primeros** (30') y **el 4 se hace en conjunto al final** (10'), proyectado, porque el
resultado es una decisión de proyecto y conviene discutirla entre todos.

Los tres primeros ejercicios están graduados: el 1 es el más guiado, el 3 el más abierto.

---

## 110–120' · Cierre

Puesta en común: cada pareja muestra su gráfico en 2 minutos y responde **una** pregunta: *¿qué se
ve ahora que no se veía antes?*

Las tres ideas de la clase:

1. **Un gráfico puede ser claro y aun así mentir.** La integridad no es un problema estético.
2. **La pregunta define la herramienta**, no el revés. La taxonomía es una guía, no un dogma: en el
   caso ENGHo del informe, waffle y slope son ambos defendibles, y lo que decide es una pregunta
   analítica (¿nos importan las variaciones chicas o solo las grandes?).
3. **La paleta es una decisión metodológica**, no de diseño gráfico. Una escala no uniforme viola el
   primer principio de Tufte.

**Anticipo de la clase 3:** ya sabemos leer y elegir gráficos. Falta el circuito completo: de dónde
salen estos datos, cómo se actualizan, y cómo se publican con la narrativa correcta.
