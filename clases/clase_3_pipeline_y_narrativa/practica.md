# Práctica - Clase 3

**Duración:** 45' (Bloque A) + 10' (puesta en común) + 5' (pausa) + 35' (Bloque B) = 95 minutos.
**En parejas de perfiles mezclados**, igual que en la Clase 2: quien comunica define la pregunta y
redacta el título; quien mantiene escribe el código.

Todo corre sobre los CSV ya versionados de `data/inputs_md/` - **no hace falta descargar
microdatos**.

---

## Bloque A - Un gráfico desde cero (45')

### El ejercicio

Elegí un CSV del [catálogo de datos](../materiales/catalogo_datos.md) - **uno que no hayas usado
en la Clase 1 ni en la Clase 2** - y armá un gráfico entero, de punta a punta, sin ningún `______`
para completar. El archivo de trabajo es `ejercicios/01_grafico_desde_cero.R`.

### Paso 0 - La pregunta *(5')*

Elegí tu CSV en `materiales/catalogo_datos.md` y escribí, en una oración, qué querés contestar.

- **Mala:** "Graficar la tasa de desocupación."
- **Buena:** "¿La desocupación de La Rioja está por debajo del NOA desde 2021?"

Si no se te ocurre una, usá la pregunta sugerida del catálogo para ese CSV.

### Paso 1 - Mirar el dato *(5')*

Antes de escribir una sola línea de `ggplot()`: `glimpse()` del CSV. Contestá en un comentario -
¿qué identifica una fila?, ¿qué período cubre `fecha`?, ¿hay `NA`?

### Paso 2 - Elegir la marca *(5')*

Con la tabla de `materiales/checklist_visualizacion.md` §1 ("¿Qué gráfico?"): ¿qué operación es tu
pregunta (parte de un todo, ranking, brecha, correlación, cambio en el tiempo)? ¿Qué marca le
corresponde? Anotalo en un comentario, antes de graficar.

### Paso 3 - El gráfico *(15')*

Escribilo desde una hoja en blanco. Tenés disponibles las herramientas del proyecto (todas en
`style/fundar_monitor_theme.R`): `theme_monitor()`, `theme_monitor_barras_h()`,
`scale_color_fundar_multi()`, `scale_fill_fundar_multi()`, `fuente_fundar()`, `puntos_etiqueta()`.

Si tu CSV trae `fecha` como texto tipo `"2007-Q1"` (los de EPH), convertila con
`lubridate::yq()` para tener el eje X con fechas reales, no las 72 etiquetas rotadas (la trampa que
vimos en la Clase 2). Si tu CSV es de SIPA (`03_`, `05_`, `07_`), `fecha` ya es `Date`.

### Paso 4 - Los tres campos de texto *(10')*

Con `materiales/checklist_visualizacion.md` §3 al lado:

| Campo | Qué tiene que decir |
|---|---|
| **Título** | El hallazgo, afirmado. Una oración que se pueda leer sola. **No** el nombre de la variable. |
| **Subtítulo** | Unidad, universo, período, y cualquier transformación aplicada. |
| **Caption** | Fuente completa **y la advertencia metodológica que tu fila del catálogo marca** - no la inventes, ya está escrita ahí. |

### Paso 5 - Guardar y auto-auditar *(5')*

`ggsave()` a `outputs/plots/clase3_<nombre_pareja>.png`. Antes de mostrarlo a la sala, repasá
`materiales/checklist_visualizacion.md` §2: eje Y en cero (o el corte justificado y marcado), entre
6 y 8 marcas por eje, el color codificando lo que tiene que codificar.

Si te trabás, `soluciones/01_ejemplos_resueltos.R` tiene tres ejemplos completos - sobre otros
CSV y otras marcas, para no repetir tu propia elección.

---

## Puesta en común *(10')*

Proyectá tu PNG y contá: qué pregunta elegiste, qué marca, y tu título. Vamos a compararlo con los
de las otras parejas.

---

## Pausa *(5')*

---

## Bloque B - De dónde salió esa columna (35')

### El ejercicio

Trabajás sobre el **mismo CSV** que elegiste en el Bloque A. El archivo es
`ejercicios/02_rastreo_pipeline.R`. Sin descargar microdatos, sin red: la herramienta es
**Ctrl+Shift+F** (Find in Files) de RStudio, buscando el nombre de tu CSV y de sus columnas dentro
de `src/`.

### B1 - El rastreo *(15')*

Según qué CSV elegiste, seguí el camino EPH o el camino SIPA (las preguntas exactas están en
`ejercicios/02_rastreo_pipeline.R`):

**Camino EPH** (`04_`, `09a_`, `10_`, `12_`, `13a_`, `13b_`, `03b_`): qué script escribió el CSV;
de qué `.rds` lo leyó y quién escribió ese `.rds`; en qué línea se creó la variable que se está
sumando; de qué columna cruda de la EPH depende, y dónde se pidió; qué función convirtió el código
numérico en texto legible, y por qué importa el orden en que se aplica.

**Camino SIPA** (`03_`, `05_`, `07_`): qué script prep-ó el CSV y de qué `.xlsx`; qué
transformación de formato necesitó; dónde se homologan los nombres de provincia. **Si tu CSV es
`07_`**: puede que no encuentres un script que lo escriba. Si es así, no es que te falte buscar
mejor - documentalo como lo que es.

### B2 - Dibujar el diagrama *(10')*

En papel, a partir de lo que encontraste: las etapas del pipeline, qué archivo produce cada una, y
dónde cae la línea de lo que está versionado en git.

### B3 - Auditar el CSV sin microdatos *(10')*

Si tu CSV trae numerador y denominador (`04_`, `09a_`, `10_`, `12_`, `13a_`, `13b_`), podés
recalcular la tasa y compararla con la que ya está escrita:

```r
read_csv("./data/inputs_md/04_tasa_desoc.csv") %>%
  mutate(control = desoc / pea * 100) %>%
  summarise(dif_maxima = max(abs(tasa_desoc - control)))
# → tiene que dar un número minúsculo (error de redondeo, no un problema del cálculo)
```

Si tu CSV es de SIPA o es `03b_` (un promedio ponderado, sin numerador/denominador propio), auditá
la estructura en cambio:

```r
read_csv("./data/inputs_md/____.csv") %>%
  count(jurisdiccion, fecha) %>%
  filter(n > 1)
# → tiene que devolver 0 filas
```

**Preguntas para cerrar el bloque:**

- ¿Por qué `data/inputs_md/` está versionado en git y `data/raw_data/` no?
- Sale una onda nueva de la EPH: ¿qué corrés, y qué NO volvés a correr?
- ¿Y si además agregaste una variable nueva? (pista: no alcanza con agregarla al vector de
  variables a descargar)

Si te trabás, las respuestas completas con `archivo:línea` están en
`soluciones/02_rastreo_respuestas.md`.

---

## Cierre

Traé a la puesta en común:

- El diagrama que dibujaste en B2. Lo comparamos con el de referencia.
- Una cosa del circuito que te haya resultado más frágil de lo que esperabas.

---

## Opcional, si te sobra tiempo - Publicar tu gráfico

Los pasos para que tu gráfico del Bloque A aparezca en el dashboard, y para subirlo por PR, no
entran en el tiempo de la clase, pero son cortos y están completos en
[`materiales/cheatsheet_repo.md`](../materiales/cheatsheet_repo.md) ("Agregar un indicador al
dashboard" y "Publicar").

También queda, como recorrido opcional más largo para practicar el circuito completo con otro
indicador de punta a punta (cálculo → gráfico → dashboard → PR), el ejercicio de
[`anexo/`](anexo/): agregar la tasa de actividad al monitor.
