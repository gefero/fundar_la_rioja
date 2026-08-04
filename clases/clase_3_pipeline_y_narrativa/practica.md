# Práctica — Clase 3

**Duración:** 50 minutos. **En parejas de perfiles mezclados.**

---

## El ejercicio: agregar un indicador nuevo al monitor

Vamos a recorrer el circuito completo, de punta a punta, con un indicador que **hoy no existe en el
proyecto**: la **tasa de actividad** (población económicamente activa sobre población total).

Es una buena elección por dos razones. Primero, porque completa el trío clásico del mercado de
trabajo: hoy el monitor tiene tasa de empleo y tasa de desocupación, pero no la de actividad, que es
la que dice **cuánta gente se ofrece al mercado**. Y segundo, porque se puede derivar de dos CSV que
**ya están versionados**, sin descargar un solo microdato:

- `data/inputs_md/04_tasa_desoc.csv` tiene la columna **`pea`** (población económicamente activa,
  ponderada).
- `data/inputs_md/10_tasa_empleo.csv` tiene la columna **`pob_tot`** (población total, ponderada).

```
tasa_actividad = pea / pob_tot × 100
```

---

## Paso 1 — El cálculo *(perfil mantenimiento, 10')*

**Archivo:** `ejercicios/01_tasa_actividad_calculo.R` → copialo a `src/06_prep_tasa_actividad.R`

Hacé el `left_join()` de los dos CSV por `fecha` y `la_rioja_region`, calculá la tasa y escribí
`data/inputs_md/06_tasa_actividad.csv`.

> **Por qué `06_prep_`:** el repositorio ya usa esa convención para los scripts que preparan un CSV
> a partir de otra fuente (ver `03_prep_salarios_privados_SIPA.R` y
> `05_prep_puestos_asalariados_privados.R`). El número 06 estaba libre.

---

## Paso 2 — Verificar *(los dos, 5')*

Antes de graficar nada. Tres chequeos, en este orden:

1. **¿Cuántas filas quedaron?** Tienen que ser **216** = 72 trimestres × 3 regiones. Si son menos,
   el join perdió filas; si son más, duplicó.
2. **¿Hay `NA`?** No tiene que haber ninguno.
3. **La verificación conceptual, que es la importante:**

   ```
   tasa_actividad ≈ tasa_empleo + (desocupados / pob_tot × 100)
   ```

   Porque la PEA son los ocupados más los desocupados. Si esta identidad no se cumple, algo está
   mal en el join.

**Pregunta:** ¿por qué la tasa de actividad **no** es igual a `tasa_empleo + tasa_desoc`? Las dos
son porcentajes, pero no del mismo denominador. ¿Cuál es cuál?

---

## Paso 3 — La narrativa *(perfil comunicación, 10')*

Antes de que se escriba el `labs()`, mirá los datos y decidí **qué historia cuenta este indicador**.

Abrí el CSV que produjo tu compañero o compañera y mirá la serie de La Rioja: ¿sube, baja, se
mantiene? ¿Cómo se compara con el NOA y con el resto del país? ¿Hay algún quiebre?

Después escribí los tres campos, siguiendo la tabla de la clase:

- **Título** — el hallazgo afirmado, una oración que se lea sola. **No** "Tasa de actividad".
- **Subtítulo** — unidad, universo, período.
- **Caption** — la fuente completa y las advertencias metodológicas que correspondan.

**Preguntas para decidir el caption:**

- ¿Hay que advertir sobre el quiebre de 2015/2016? ¿Aplica a este indicador o solo a los de
  ingresos? (Pista: ¿este cálculo usa `PONDIIO`?)
- ¿Hay que advertir algo sobre el tamaño de muestra de La Rioja?
- La serie tiene un hueco entre 2015-T3 y 2016-T1. ¿Se ve en el gráfico? ¿Debería?

---

## Paso 4 — El gráfico *(perfil mantenimiento, 10')*

**Archivo:** `ejercicios/02_tasa_actividad_viz.R` → copialo a `src/06_tasa_actividad.R`

Seguí el patrón de `src/04_desoc.R`, y aplicá lo que aprendimos:

- La paleta y el tema del proyecto.
- **El eje X con fechas reales**, no las 72 etiquetas de texto (clase 2).
- El eje Y arrancando en cero.
- Los textos que escribió tu compañero o compañera en el paso 3.

Guardá el PNG en `outputs/plots/06_tasa_actividad.png`.

---

## Paso 5 — El dashboard *(los dos, 10')*

Registrá el indicador en `INDICADORES`, en `dashboard/R/data.R`. Va con `shape = "A"` (serie
trimestral regional, una fila por fecha-región), que es la forma que tiene tu CSV.

Después:

```r
shiny::runApp("dashboard")
```

**No hay que tocar ni una línea de la app.** Si el registro está bien, el indicador aparece solo en
el selector, con sus filtros de región y rango temporal, su descarga de PNG y CSV, y su versión
plotly. También aparece en el sitio estático al renderizar `dashboard/index.qmd`.

**Si no aparece**, revisá en este orden: el nombre del CSV, el nombre de `y_var`, y que el `topico`
sea uno de los tres de `TOPICOS`.

---

## Paso 6 — Publicar *(los dos, 5')*

```bash
git checkout -b tasa-actividad
git add src/06_prep_tasa_actividad.R src/06_tasa_actividad.R \
        data/inputs_md/06_tasa_actividad.csv dashboard/R/data.R \
        outputs/plots/06_tasa_actividad.png
git commit -m "Agrego indicador de tasa de actividad"
git push -u origin tasa-actividad
```

Y abrir el Pull Request en GitHub.

**Pregunta:** el workflow `.github/workflows/dashboard.yml` se dispara con cambios en
`data/inputs_md/`. ¿Se disparó con este push? ¿Por qué sí o por qué no?

---

## Variante avanzada *(solo si tenés los microdatos descargados)*

Calculá la tasa de actividad **directamente desde el dataset canónico**, agregando el bloque a
`src/02_indicadores_eph_individuo.R`. Las variables ya están: `pea` y `PONDERA`. Son seis líneas,
copiando el patrón del bloque de tasa de empleo.

Después **contrastá los dos resultados**. Tienen que dar exactamente igual.

Si no dan igual, encontrar por qué es el mejor ejercicio de todo el taller: significa que alguno de
los dos caminos tiene un filtro, un `ANO4 >=` o un `na.rm` que el otro no tiene.

---

## Cierre

Traé a la puesta en común:

- El título que escribieron (paso 3). Los vamos a comparar entre parejas.
- Una cosa del circuito que les haya resultado más frágil de lo que esperaban.
