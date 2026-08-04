# Clase 1 — Gramática de gráficos y percepción

**Duración:** 120 minutos · **Teoría:** 65' · **Práctica:** 45' · **Cierre:** 10'

**Material de slides:** `clases/Copia de Pract_Clase_1_introducción.pdf`, **diapositivas 1 a 57**
(el bloque "Algunas nociones conceptuales"). El segundo bloque del deck —"Integridad visual",
diapositivas 58 a 169— **no se da en esta clase**: abre la clase 2.

**Objetivo de la clase:** que al terminar, cualquiera de los dos perfiles pueda mirar un gráfico del
monitor y descomponerlo en *qué dato está mapeado a qué propiedad visual*, y decir si ese mapeo es
una buena decisión o no.

---

## 0–10' · Apertura

**Slides:** portada del deck (1). **Slides nuevas a hacer: 2.**

Presentar el taller entero antes de entrar en materia:

- Tres clases de dos horas: (1) cómo se lee un gráfico, (2) cómo se elige, (3) cómo se produce y se
  publica.
- **El público es mixto y eso es a propósito.** Hay gente que va a mantener el repositorio y
  actualizar los datos, y gente que va a comunicar los resultados. Las tres clases tienen teoría
  común y práctica compartida.
- La idea que ordena todo el taller, y que conviene dejar escrita en una slide:

  > Los CSV de `data/inputs_md/` son la frontera entre los dos equipos. El equipo de datos garantiza
  > que estén bien calculados y actualizados; el de comunicación decide cómo se leen.

  Mostrar el directorio real: diez archivos, uno por indicador, versionados en git. Todo lo que se
  hace hacia atrás de esa frontera es la clase 3; todo lo que se hace hacia adelante es la clase 2.

- Chequeo rápido: ¿todos corrieron `clases/materiales/00_setup.R` y vieron el gráfico de prueba?
  Resolver ahí los problemas de instalación, no durante la práctica.

---

## 10–30' · La gramática de gráficos

**Slides:** 2–11 del deck. **Slides nuevas a hacer: 2** (el código anotado, ver abajo).

### Qué se dice (slides 2–11)

Arrancar por la pregunta del deck: **¿qué es un gráfico?** Y la reformulación que la hace
productiva: ¿cómo lo describimos sucintamente, de forma que podamos *generarlo*? De ahí la idea de
Wilkinson de una **gramática**: "los principios fundamentales de un arte o una ciencia" — un
conjunto chico de reglas que combinadas generan todos los gráficos posibles, igual que la gramática
de una lengua genera todas las oraciones posibles.

Las piezas, en el orden en que las presenta el deck:

1. **Datos** — una tabla: filas (observaciones) y columnas (variables).
2. **Mapeo estético** — cada variable se asigna a una propiedad visual: A → x, C → y, D → forma.
3. **Objetos geométricos** — puntos, barras, líneas, superficies.
4. **Escalas** — la traducción de los valores de los datos a coordenadas y colores que la máquina
   puede dibujar. Las slides 8–11 muestran la secuencia: datos → escalado → espacio estético →
   objetos producidos → plot final.

El ejemplo del deck (slides 6–8) es un scatterplot de A y C con la forma mapeada a D. Recorrerlo
como está: es corto y hace el punto.

> **Ojo con la errata de la slide 8:** el mapeo dice `A => x, B => y` cuando debería decir
> `A => x, C => y` (así aparece bien en la slide 7). Corregirlo en el deck.

### El anclaje en el repo (lo importante de este bloque)

Acá el taller deja de ser abstracto. Abrir **`src/04_desoc.R`** —tiene 23 líneas— y leerlo en voz
alta como si fuera la gramática hecha código:

```r
df <- read_csv('./data/inputs_md/04_tasa_desoc.csv')   # 1. DATOS

df_plot %>%
  ggplot(aes(x = fecha, y = tasa_desoc,                # 2. MAPEO ESTÉTICO
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +                         # 3. OBJETO GEOMÉTRICO
  scale_color_fundar_multi(name = "Región") +          # 4. ESCALA (dato → color)
  ylim(0, 20) +                                        # 4. ESCALA (dato → posición y)
  theme_monitor() +                                    # 5. TODO LO QUE NO ES DATO
  labs(title = ..., x = ..., y = ..., caption = ...)   # 6. ANOTACIÓN
```

Los puntos a marcar:

- **`ggplot2` se llama así por esto**: "gg" es *grammar of graphics*. El `+` no es decorativo, es
  el operador que compone las capas de la gramática.
- **La distinción clave: dentro o fuera de `aes()`.** `color = la_rioja_region` va *dentro* porque
  el color depende del dato. `linewidth = 0.7` va *fuera* porque es una decisión constante, no un
  mapeo. Esta confusión es el error nº 1 de quien arranca con ggplot.
- **`theme_monitor()` no toca los datos.** Todo lo que hace es decidir cómo se ve lo que no es dato:
  fondo, grilla, tipografía, posición de la leyenda. Por eso puede vivir en un archivo aparte
  (`style/fundar_monitor_theme.R`) y aplicarse igual a los diez indicadores.
- **Los diez scripts de visualización del repo son variaciones de este mismo esqueleto.** Quien
  entienda estas seis líneas puede leer cualquiera de ellos.

Para el perfil comunicación, la conclusión es: *no hace falta saber programar para leer esto*. Se
puede mirar un script y saber qué variable está en cada eje y de qué depende cada color.

---

## 30–45' · Marcas y canales

**Slides:** 26–32 del deck. **Slides nuevas a hacer: 1** (la grilla con los tres PNG del repo).

### Qué se dice (slides 26–32)

Presentar la nomenclatura de Munzner, que es la misma idea con otro vocabulario y más precisión:

- Una **marca** es el elemento geométrico primitivo, clasificado por dimensiones espaciales:
  0D puntos, 1D líneas, 2D áreas, 3D volúmenes (raros y desaconsejados). En redes se suman marcas
  de **conexión** (una línea que vincula dos ítems) y de **contención** (un área que anida).
- Un **canal** es una propiedad de la marca que puede variar para transmitir información: posición
  espacial, color (con sus tres sub-canales: matiz, saturación, luminancia), tamaño (longitud, área,
  volumen), orientación, curvatura, forma, movimiento.
- **Los canales son independientes de la marca.** Una línea puede variar en color, grosor,
  punteado; un punto en tamaño, forma, color.

La slide 31 es el ejercicio de lectura: cuatro gráficos, y para cada uno, ¿qué atributos se
representan?, ¿cuántos son cuantitativos?, ¿qué marcas hay?, ¿qué canales se usan? Hacerlo con la
sala, en voz alta.

### El anclaje en el repo

Proyectar tres PNG de `outputs/plots/` y desarmarlos con la misma grilla de preguntas. Sugeridos,
porque escalan en complejidad:

| Gráfico | Marca | Canales | Atributos |
|---|---|---|---|
| `04_desoc.png` | línea (1D) | pos. x = tiempo · pos. y = tasa · matiz = región | 3 (2 cuantitativos, 1 categórico) |
| `03b_salarios_registrados_EPH.png` | línea + punto + texto | pos. x, pos. y, matiz = sector, **región espacial** = facet | 4 |
| `13a_nbi_hogares.png` | línea | pos. x, pos. y, matiz = región | 3 |

El caso interesante es el segundo: **el facetado es un canal**. La "región espacial" —en qué panel
cae la marca— codifica la zona, y eso libera el matiz para codificar el sector. Es la misma cantidad
de información que si hubiéramos puesto seis líneas de colores en un solo panel, pero mucho más
legible. Es la primera aparición de los *small multiples*, que vuelven en la clase 2.

---

## 45–70' · Efectividad de los canales

**Slides:** 33–55 del deck. **Slides nuevas a hacer: 1** (la paleta del repo como ejemplo).

### Qué se dice (slides 33–55)

El punto central de la clase: **no todos los canales transmiten igual de bien al sistema perceptivo
humano.** Hay cuatro criterios (slide 33):

1. **Precisión / efectividad** — ¿qué tan bien vemos la diferencia entre dos valores?
2. **Discriminabilidad** — ¿cuántos niveles distintos podemos separar en ese canal?
3. **Separabilidad** — ¿los canales interfieren entre sí?
4. **Saliencia (pop-out)** — ¿hay algo que salte a la vista sin buscarlo?

**Precisión (slides 34–36).** Somos buenos comparando posiciones sobre una escala común; peores
sobre escalas no alineadas; mucho peores con ángulos (adiós gráficos de torta); pésimos con áreas
—de hecho **sobreestimamos** las diferencias de área—. Y nos cuesta mucho evaluar cambios de
pendiente, que además dependen del *aspect ratio* del gráfico.

**Separabilidad (slides 37–38).** El cuadro de la slide 37 es el que hay que dejar grabado:
posición + matiz son separables (2 grupos limpios en cada canal); tamaño + matiz tienen interferencia
leve; ancho + altura, media; rojo + verde, alta (uno ya no ve dos canales sino cuatro categorías).
La moraleja: **agregar canales no es gratis.** Cada canal nuevo satura al espectador y puede
interferir con los que ya estaban.

**Saliencia (slides 39–45).** La secuencia de pop-out es la mejor demostración en vivo del deck:
buscar el punto azul es instantáneo con un solo canal distractor, y se vuelve difícil a partir del
tercer panel. Detenerse en la slide 45: muchos canales funcionan como pop-out (inclinación, grosor,
forma), pero **los pares de líneas paralelas no**.

**Contexto y relatividad (slides 46–50).** Nuestro sistema perceptivo evalúa **diferencias
relativas, no absolutas**. La percepción de la luminancia depende del entorno; los bordes cambian lo
que vemos. De ahí la conclusión práctica: **el mismo color puede leerse distinto según lo que tenga
al lado.**

**Paletas (slides 51–55).** Presentación breve —el desarrollo completo es la clase 2—: hay paletas
para variables cualitativas, secuenciales y divergentes, y elegir mal la familia es un error
conceptual, no estético.

### El anclaje en el repo

Mostrar el código de la paleta, `style/fundar_monitor_theme.R:25-31`:

```r
FUNDAR_MULTI <- c(
  "serie_1" = "#A8DCC8",   # Verde menta claro    → 1. Resto país
  "serie_2" = "#C8C87A",   # Amarillo oliva       → 2. NOA-Resto
  "serie_3" = "#2D6E6E",   # Verde azulado oscuro → 3. La Rioja (énfasis)
  ...
```

y la función que asigna la región, `src/utils_eph.R:97-104`:

```r
la_rioja_region = case_when(
  AGLOMERADO == "La Rioja"                        ~ "3. La Rioja",
  AGLOMERADO != "La Rioja" & REGION == "Noroeste" ~ "2. NOA-Resto",
  TRUE                                            ~ "1. Resto país")
```

Dos decisiones deliberadas de diseño escondidas en ese código, y conviene explicitarlas porque son
exactamente la teoría que se acaba de dar:

1. **La Rioja es la única serie oscura.** Las otras dos son claras y de baja saturación. No es un
   capricho de color: es **saliencia por contraste de luminancia**. La serie protagonista aparece
   sin que el lector la busque, que es todo el punto de la secuencia de pop-out de las slides 39–45.
2. **Los prefijos numéricos `1.`, `2.`, `3.` no son cosméticos.** Fuerzan el orden alfabético del
   factor, y con eso el orden en que ggplot dibuja: La Rioja se dibuja última y queda **encima** de
   las otras dos cuando se cruzan. Es una solución de una línea a un problema de oclusión.

Pregunta para la sala, que abre la práctica: **¿qué pasaría si en vez de matiz hubiéramos usado la
forma del punto para distinguir regiones?** (Respuesta corta: la forma es el peor canal para
variables categóricas, y ni hablar sobre líneas.) Se comprueba en el ejercicio 3.

---

## 70–75' · Pausa

---

## 75–110' · Práctica

Consignas completas en [`practica.md`](practica.md). Los scripts están en `ejercicios/`.

**Slides nuevas a hacer: 3** (una por consigna).

| Ejercicio | Tiempo | Qué se hace |
|---|---|---|
| `01_gramatica_capas.R` | 15' | Reconstruir `04_desoc.R` una capa por vez |
| `02_mapeos_alternativos.R` | 15' | Tres mapeos distintos del mismo dato de NBI |
| `03_romper_canales.R` | 10' | Mapear la región a `shape` y a `size`, y sufrirlo |

**Cómo conducirla.** Los ejercicios 1 y 3 conviene hacerlos guiados, todos a la vez, proyectando y
esperando a que la sala ejecute cada paso. El 2 es el único de exploración individual: dar los diez
minutos, recorrer la sala, y guardar los resultados para la puesta en común.

Para el perfil comunicación que no programe: el ejercicio 1 es autoexplicativo (se ejecuta línea por
línea y se mira el resultado), y en el 2 y el 3 conviene sentarlos con alguien del perfil
mantenimiento. Que **miren y opinen** sobre cuál versión funciona mejor es exactamente el trabajo
que van a hacer en la clase 2.

---

## 110–120' · Cierre

Tres ideas para llevarse:

1. **Todo gráfico es un mapeo de datos a propiedades visuales.** Leer un gráfico es reconstruir ese
   mapeo; hacer un gráfico es elegirlo.
2. **Los canales no son intercambiables.** Posición > longitud > área > ángulo > forma. Elegir el
   canal es una decisión sobre qué tan preciso va a ser el lector.
3. **La saliencia se diseña.** Que La Rioja salte a la vista en nuestros gráficos es una decisión
   que está escrita en dos líneas de código.

Puesta en común del ejercicio 2: proyectar dos o tres versiones distintas y discutir **a qué
pregunta responde mejor cada una**. Sin ganador único: el punto es que la pregunta define el
gráfico.

**Anticipo de la clase 2:** hasta acá vimos si un gráfico *se entiende*. La próxima vemos si además
*dice la verdad* —el caso Challenger, el factor de mentira— y cómo elegir la herramienta correcta a
partir del catálogo de Argendata.
