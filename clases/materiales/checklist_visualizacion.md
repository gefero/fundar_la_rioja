# Checklist de visualización

Referencia de una página para tener al lado mientras se arma un gráfico o un producto de
comunicación. Fuentes: Tufte (1983, 1997), Munzner (2014), Healy (2019) y el
[informe de Argendata](Informe_final_argendata.pdf).

---

## 1. Antes de graficar — ¿qué gráfico?

**Primero la pregunta, después el gráfico.** No al revés. Definí en una frase qué querés que el
lector se lleve, y recién ahí elegí la herramienta.

| ¿Qué operación estás haciendo? | Corte transversal | Serie de tiempo |
|---|---|---|
| **Parte de un todo** | waffle chart (sin niveles anidados) · treemap (con niveles anidados) | waffle facetado · slope chart |
| **Rankear unidades** | barras horizontales ordenadas | slope chart (2 momentos) · bump chart (muchos momentos) |
| **Mostrar brechas** | Cleveland dot plot | líneas con la brecha implícita (área entre las dos líneas) |
| **Correlacionar variables** | scatter plot | líneas facetadas (una por variable), nunca doble eje |
| **Cambios en el tiempo** | — | ≤5 momentos: slope · 5–50: líneas · >50: área · muchas categorías: spaghetti |
| **Distribuciones** | boxplot · densidad | líneas con banda de variabilidad (ribbon) |

Además:

- [ ] **¿Cuántas categorías tiene la variable?** Más de 12 colores no se distinguen. Si hay más,
      agrupá en categorías más amplias o dejá una categoría "resto".
- [ ] **¿Hay demasiadas series superpuestas?** Probá *small multiples* (facetado): mismos ejes y
      escalas, un panel por categoría. Compara mucho mejor que superponer.
- [ ] **¿La granularidad del gráfico coincide con la del texto?** Si el análisis habla de cuatro
      rubros, no muestres doce.

---

## 2. Al graficar — integridad y legibilidad

**Ejes**

- [ ] El eje Y **empieza en cero**. Excepción admitida: líneas facetadas donde lo que se compara son
      variaciones relativas, no niveles. Si no arranca en cero, marcá el quiebre explícitamente.
- [ ] Entre **6 y 8 marcas** por eje. Menos deja al lector sin referencias; más satura. En ejes
      temporales largos, mostrá años y no todos los períodos.
- [ ] Sin marcas secundarias.
- [ ] Etiquetas **sin ceros ni decimales innecesarios**: si son millones, escribí "1.000" y aclará
      "en miles de millones" en el título del eje.
- [ ] Las **unidades van en el título del eje** ($, %, miles de puestos), no repetidas en cada marca.

**Tinta**

- [ ] Nada de 3D, sombras, degradados de fondo ni perspectiva. Distorsionan la percepción.
- [ ] Si podés borrar un elemento sin perder información, borralo.
- [ ] Evitá combinar geometrías distintas (barras + puntos) para representar variables de la misma
      naturaleza: confunde en vez de aclarar.

**Color**

- [ ] **Variable cualitativa** → variar el *tono* (hue), con saturación y luminancia parejas.
- [ ] **Variable cuantitativa u ordinal** → variar *luminancia* o *saturación*, no el tono.
      Escala secuencial si el dominio es de una sola dirección; divergente si hay un punto medio con
      sentido.
- [ ] La escala es **perceptualmente uniforme** (pasos iguales en los datos se ven como pasos iguales
      en el color). Si no, el gráfico inventa cortes que no están en los datos. Viridis y plasma
      cumplen; jet es el contraejemplo clásico.
- [ ] Se distingue con **daltonismo**. Verificá con `colorspace::deutan()` (ver
      `src/test_escalas.R`).
- [ ] El color destaca lo que querés destacar. En este proyecto, La Rioja va en el teal oscuro
      (`#2D6E6E`) y el resto en tonos claros: el contraste de luminancia hace que salte a la vista.

**Factor de mentira**

> `factor de mentira = proporción en el gráfico ÷ proporción en los datos`
> Debería dar 1. Fuera del rango 0,95–1,05, el gráfico está distorsionando.

- [ ] La longitud/área dibujada es proporcional al número representado.
- [ ] La dimensionalidad del gráfico no supera la de los datos (un dato de una dimensión no se
      representa con un área ni con un volumen).

---

## 3. Al publicar — narrativa

- [ ] **El título afirma el hallazgo**, no nombra la variable.
      *"Tasa de desocupación"* → **"La desocupación en La Rioja se ubica por debajo del NOA desde
      2021"**.
- [ ] El **subtítulo** aclara unidad, universo y período: *"% de la PEA. Aglomerado La Rioja,
      2007–2025, trimestral."*
- [ ] El **caption** lleva la fuente completa y las **advertencias metodológicas**: quiebres de
      serie, cambios de metodología, períodos sin relevamiento. Ejemplo del repo: el gráfico de
      salarios avisa del cambio de metodología de ingresos de la EPH en 2015–2016 y dibuja la línea
      punteada del quiebre.
- [ ] Series monetarias: **están deflactadas o expresadas en unidades constantes**. Una serie en
      pesos corrientes muestra inflación, no el fenómeno.
      *(Pendiente conocido: el indicador 03 del repo está en pesos corrientes.)*
- [ ] Si el dato viene de una muestra y el dominio es chico (La Rioja lo es), **¿la variación que
      estás contando es real o es ruido muestral?** Promediar las cuatro ondas del año estabiliza.
- [ ] Todo elemento no obvio del gráfico está explicado: qué significa una diagonal, un área
      sombreada, una línea de corte.
