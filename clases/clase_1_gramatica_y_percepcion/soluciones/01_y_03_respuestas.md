# Respuestas — ejercicios 1 y 3 (clase 1)

Los ejercicios 1 y 3 no tienen `TODO` que completar: se ejecutan tal cual y lo que se responde son
las preguntas del margen. Acá quedan las respuestas, para quien dicta y para quien quiera
verificar.

---

## Ejercicio 1 — La gramática, capa por capa

**Paso 1. ¿Qué se ve? ¿Por qué el eje x está tan cargado?**

Se ven los ejes y nada más: hay mapeo pero no hay geometría, así que no hay nada que dibujar. Es la
demostración de que `aes()` y `geom_*()` son cosas distintas.

El eje x está cargado porque `fecha` es **texto** (`"2007-Q1"`), no una fecha. ggplot lo trata como
variable categórica y dibuja una marca por cada uno de los 72 valores. Con un `Date`, elegiría
marcas cada N años (ver el bloque EXTRA).

**Paso 2. ¿Por qué dibuja una sola línea en zigzag?**

`geom_line()` une los puntos en orden de x. Como para cada trimestre hay **tres** filas (una por
región) y ggplot no sabe que son series distintas, las une todas: sube a Resto país, baja a NOA,
salta a La Rioja, pasa al trimestre siguiente. El zigzag es literalmente el recorrido entre las tres
regiones, 72 veces.

Le falta saber **qué filas pertenecen a la misma serie**. Eso es `group`.

**Paso 4. ¿Cuál es la regla de dentro/fuera de `aes()`?**

> Dentro de `aes()` va lo que **depende de una variable de los datos**. Fuera va lo que es una
> **constante** para todas las observaciones.

`color = la_rioja_region` depende del dato → dentro, y ggplot genera una leyenda.
`linewidth = 0.7` es igual para todas las líneas → fuera.

Si se pone `linewidth = 0.7` *dentro* de `aes()`, ggplot interpreta que `0.7` es una variable con un
solo valor: crea una escala y **agrega una leyenda absurda** que dice "0.7". Vale la pena hacerlo en
vivo, es muy ilustrativo.

**Paso 4 bis. ¿Qué cambió respecto del paso 3?**

Nada en la geometría: las tres líneas ya estaban separadas por `group`. Lo que cambió es que ahora
la región está codificada **también** en el color, y aparece la leyenda. Es un caso de *redundancia*
de canales: la misma variable en dos canales (agrupamiento + matiz). La redundancia bien usada es
buena práctica —el informe de Argendata la recomienda explícitamente—, no un desperdicio.

**Paso 5. ¿Cuánto tardás en encontrar La Rioja antes y después?**

Con la paleta por defecto de ggplot (tres colores de luminancia y saturación parejas) hay que ir a
la leyenda, leer cuál es La Rioja, volver al gráfico y buscar ese color. Con
`scale_color_fundar_multi()` la serie oscura salta sola: el contraste de luminancia funciona como
*pop-out* preatentivo.

**Paso 6. ¿El tema cambió algún dato?**

No. Ni uno. `theme_monitor()` solo toca elementos no-datos: fondo, grilla, tipografía, márgenes,
posición de la leyenda. Por eso el mismo tema sirve para los diez indicadores del monitor.

Cuidado con no confundirlo con `ylim(0, 20)`, que **sí** es una escala y **sí** puede cambiar lo que
se ve (si algún valor cayera fuera del rango, ggplot lo descarta y avisa con un warning).

---

## Ejercicio 3 — Romper el gráfico a propósito

**Versión A (color).** Encontrar La Rioja es instantáneo: la serie oscura contrasta contra dos
claras. Los cruces se siguen sin problema. Con seis series el matiz todavía funciona, aunque
empieza a costar (el máximo razonable ronda 6–12 colores, contando fondo y líneas).

**Versión B (forma).** Encontrar La Rioja obliga a ir a la leyenda, memorizar el símbolo y
escanear el gráfico buscándolo. En los cruces se pierde el hilo por completo. Con seis series es
inviable: la forma es el canal de **peor discriminabilidad** para variables categóricas. Además acá
hubo que agregar puntos, porque la forma no se puede aplicar a una línea — el canal ni siquiera
existe para esa marca.

**Versión C (tamaño).** Se lee mejor que la forma, pero introduce un problema conceptual: el grosor
tiene **ordinalidad implícita**. Una línea más gruesa se lee como "más importante" o "más grande", y
eso es información que el gráfico está inventando: la región es una variable puramente categórica,
sin orden intrínseco. Es información falsa agregada por la codificación.

(Matiz: el proyecto tiene `scale_linewidth_larioja()` en el tema viejo `fundar_larioja_theme.R`, que
usa el grosor **de forma deliberada y redundante** para reforzar el énfasis en La Rioja. Esa es la
diferencia: ahí el grosor no es el único canal, refuerza lo que ya dice el color.)

**Bonus (paleta plana).** El matiz sigue distinguiendo las tres regiones perfectamente —nadie las
confunde—, pero La Rioja deja de saltar a la vista: hay que buscarla. La conclusión, que es la que
importa: **distinguir y destacar son cosas distintas.** El matiz distingue; el contraste de
luminancia destaca. La paleta del proyecto usa las dos porque tiene un protagonista.

Cuándo usaría cada una: la paleta del proyecto para un informe sobre La Rioja; la plana para un
informe que compara tres regiones en pie de igualdad, donde destacar una sería tomar partido
visualmente.
