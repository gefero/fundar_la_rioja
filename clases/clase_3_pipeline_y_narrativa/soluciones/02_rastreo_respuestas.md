# Rastreo del pipeline - respuestas

Un camino completo por cada tipo de CSV. Elegí el que corresponda al que usaste en el Bloque A -
no hace falta leer los tres. Todas las referencias son `archivo:línea` verificables abriendo el
repo tal como está.

---

## Camino EPH - indicador de individuo (`04_`, `09a_`, `10_`, `12_`, `03b_`)

Ejemplo con `04_tasa_desoc.csv` (los otros cuatro son el mismo camino, cambiando la variable).

1. **¿Qué script escribió este CSV?**
   `src/02_indicadores_eph_individuo.R`. El bloque de la tasa de desocupación está en las líneas
   19-27; escribe con `write_csv('./data/inputs_md/04_tasa_desoc.csv')` en la línea 27.

2. **¿De qué objeto, y quién lo escribió?**
   De `df <- read_rds("./data/proc_data/eph_individuo.rds")` (`02_indicadores_eph_individuo.R:7`).
   Ese `.rds` lo escribe `src/01_limpieza_eph.R:94` (`write_rds(df_ind, ...)`).

3. **¿Dónde se creó la variable que se está sumando?**
   `pea` y `desocupado` se crean en `src/01_limpieza_eph.R:22-26`:
   ```r
   df_ind <- df_ind %>%
     mutate(ocupado = if_else(ESTADO == "Ocupado", 1, 0),
            desocupado = if_else(ESTADO == "Desocupado", 1, 0),
            pea = if_else(ESTADO %in% c("Ocupado", "Desocupado"), 1, 0),
            no_pea = if_else(!(ESTADO %in% c("Ocupado", "Desocupado")), 1, 0))
   ```
   (Si tu CSV es `12_`: `mayor_25_superior` sale de `01_limpieza_eph.R:29-34`. Si es `09a_`:
   `aportes_descuentos` y `asalariado_ocupado` salen de `01_limpieza_eph.R:56-66`. Si es `03b_`:
   `sector` sale de `01_limpieza_eph.R:75-82`, y el cálculo del salario ponderado está en
   `02_indicadores_eph_individuo.R:40-57`.)

4. **¿De qué columna cruda depende, y dónde se pidió?**
   `ESTADO`, pedida en `vars_individuo` en `src/00_descarga_eph.R:11`, dentro del bloque
   "laborales". La baja `descargar_eph_incremental()` (misma línea del archivo, llamada en
   `00_descarga_eph.R:27-29`) desde INDEC vía `eph::get_microdata()`.

5. **¿Qué convirtió el código en texto, y por qué importa el orden?**
   `organize_labels()`, llamada dentro de `limpiar_base_eph()` en `src/utils_eph.R:77`. El orden
   importa porque en `utils_eph.R:85-86`:
   ```r
   mutate(across(all_of(cols_a_character), as.character)) %>%   # ESTADO acá
   mutate(across(!all_of(cols_a_character), quitar_labelled))
   ```
   `as.character()` sobre un objeto `labelled` devuelve la **etiqueta** ("Ocupado"). Si el orden se
   invirtiera, `quitar_labelled()` (que hace `unclass()`, `utils_eph.R:61-67`) pelaría la clase
   `labelled` de `ESTADO` primero, y el `as.character()` posterior devolvería el **código** ("1")
   en vez de la etiqueta - y `if_else(ESTADO == "Ocupado", ...)` de `01_limpieza_eph.R:23` dejaría
   de matchear, en silencio, sin error.

---

## Camino EPH - indicador de hogar (`13a_`, `13b_`)

1. **¿Qué script escribió este CSV?**
   `src/02_indicadores_eph_hogar.R`. Escribe `13a_nbi_hogares.csv` en la línea 107 y
   `13b_nbi_poblacion.csv` en la línea 132.

2. **¿De qué objeto(s)?**
   De **dos** `.rds`, no uno: `df <- read_rds("./data/proc_data/eph_hogar.rds")` (línea 7) **y**
   `df_ind <- read_rds("./data/proc_data/eph_individuo.rds")` (línea 8) - porque `NBI_ESC` y
   `NBI_SUB` necesitan datos de individuo (niños en edad escolar, educación del jefe/a) que no
   están en la base de hogar. Los dos `.rds` los escribe `01_limpieza_eph.R` (líneas 94 y 149).

3. **¿Dónde se creó la variable?**
   `NBI_HAC` (hacinamiento) se crea en `01_limpieza_eph.R:111-120`, sobre la base de hogar sola.
   `NBI_ESC` y `NBI_SUB`, en cambio, **no** se crean en `01_limpieza_eph.R`: se calculan en
   `02_indicadores_eph_hogar.R`, cruzando hogar con el agregado de individuo (`agg_ind`, construido
   en las líneas 11-65 del mismo script - `NBI_ESC` nace ahí, línea 55; `NBI_SUB` recién en la
   segunda mutación, líneas 73-77, una vez unido a hogar; `NBI_TOT` en las líneas 78-82). Es la
   única etapa 3 del proyecto que hace un join entre dos fuentes en vez de agregar una sola.

4. **¿De qué columna cruda depende?**
   `NBI_HAC` depende de `IX_TOT` e `II1`, pedidas en `vars_hogar` en `00_descarga_eph.R:22`.
   `NBI_VIV` depende de `IV1` (`00_descarga_eph.R:20`); `NBI_SAN` de `IV8` e `IV11`
   (`00_descarga_eph.R:21`) - **no** de `IV9` (que es la ubicación del baño, no si existe: el
   comentario de `01_limpieza_eph.R:133-134` lo aclara a propósito).

5. **Etiquetado:** mismo mecanismo que el camino de individuo (`organize_labels()` +
   `utils_eph.R:76-86`), pero sobre `cols_character_hogar` (`01_limpieza_eph.R:98`).

---

## Camino SIPA - con prep (`03_`, `05_`)

Ejemplo con `03_salarios_privados_SIPA.csv`.

1. **¿Qué script lo prep-ó, de qué .xlsx?**
   `src/03_prep_salarios_privados_SIPA.R`, desde
   `data/raw_data/sipa/provinciales_serie_remuneraciones_mensual_2dig_8.xlsx` (`path_raw`, línea
   16). Escribe el CSV en la línea 119.

2. **¿Qué transformación de formato necesitó?**
   La hoja viene **traspuesta** (provincias en filas, meses en columnas, encabezado en la fila 5),
   a diferencia de `05_` donde las provincias están en columnas. El prep pivotea con
   `pivot_longer(-jurisdiccion_raw, ...)` (línea 104) y parsea las fechas del encabezado con
   `parse_fecha_header()` (definida en las líneas 67-90), que cubre tres formatos mezclados: serial
   de Excel, ISO, y texto abreviado en español (`"ene-15"`).
   (`05_prep_puestos_asalariados_privados.R` resuelve el mismo problema al revés: ahí el período
   mixto está en la primera COLUMNA, no en el encabezado - ver `parse_periodo()`, líneas 55-75.)

3. **¿Dónde se homologan los nombres de provincia, y por qué?**
   En el `tribble()` `mapa_provincias` (líneas 29-55): la fuente trae los nombres en MAYÚSCULAS
   sin acento (`"LA RIOJA"`), y el proyecto necesita los nombres canónicos (`"La Rioja"`) para
   poder clasificar cada provincia en `la_rioja_region` con la misma función que usa el resto del
   repo. El `left_join()` con ese mapa (línea 112) también **descarta** filas que no matchean
   ("GRAN BUENOS AIRES", el total nacional, notas al pie) vía `filter(!is.na(jurisdiccion))`
   (línea 113).

---

## Camino SIPA - sin prep, un vacío real del repo (`07_`)

Si elegiste `07_serie_empresas_por_jurisdiccion.csv`, el rastreo llega a un final abierto, y **eso
es correcto, no un error tuyo**.

`src/07_cant_empresas.R` **lee** ese CSV (línea 4: `read_csv("./data/inputs_md/07_serie_empresas_por_jurisdiccion.csv")`)
pero no hay, en todo `src/`, ningún script que lo **escriba**. Tampoco hay un `.xlsx` de origen en
`data/raw_data/sipa/` que corresponda (esa carpeta solo tiene los dos archivos que usan `03_prep_`
y `05_prep_`). El CSV está versionado y se usa en el dashboard y en el gráfico, pero su procedencia
no está documentada en el repositorio tal como está hoy.

**Es un hallazgo del taller, no un TODO tuyo.** Anotalo para el mapa de pendientes del cierre: es
exactamente el tipo de cosa que un equipo de mantenimiento necesita saber (¿de dónde sale este
dato? ¿cómo se actualiza?) y que hoy nadie puede contestar mirando solo el código.

---

## El diagrama de referencia

```
   INDEC (EPH)                                    SIPA (xlsx, dos reportes)
        │                                                │
        ▼                                                ▼
┌──────────────────────┐                    ┌─────────────────────────────┐
│ 00_descarga_eph.R     │  ETAPA 1           │ 03_prep_salarios_...SIPA.R  │
└──────────────────────┘  descarga           │ 05_prep_puestos_...SIPA.R   │
   → data/raw_data/eph/**/*.rds  [NO versionado]  → data/inputs_md/03_*, 05_*.csv
        │                                          [★ VERSIONADO ★, un solo paso]
        ▼
┌──────────────────────┐
│ 01_limpieza_eph.R     │  ETAPA 2 · limpieza y canonización
└──────────────────────┘  → data/proc_data/eph_{individuo,hogar}.rds  [NO versionado]
        │
        ▼
┌──────────────────────┐
│ 02_indicadores_eph_*  │  ETAPA 3 · cálculo de indicadores
└──────────────────────┘  → data/inputs_md/{04,09a,10,12,03b,13a,13b}*.csv
        │                  [★ VERSIONADO ★ - la frontera del taller]
        ├─────────────────────┬──────────────────────┐
        ▼                     ▼                       ▼
   src/NN_*.R             dashboard/              informes, placas,
   → outputs/plots/       app.R + index.qmd        presentaciones

   ¿ 07_serie_empresas_por_jurisdiccion.csv ?  →  no tiene ninguna flecha de entrada documentada.
```

El camino EPH tiene **tres** etapas (descarga → limpieza → indicadores); el camino SIPA tiene
**una sola** (prep, directo del xlsx al CSV versionado) porque no hay microdatos que limpiar. Los
dos convergen en la misma frontera: `data/inputs_md/*.csv`.

---

## Las preguntas de cierre

**¿Por qué `data/inputs_md/` está versionado y `data/raw_data/` no?**
Los microdatos (`data/raw_data/`) pesan mucho y se regeneran solos con `00_descarga_eph.R` - no
tiene sentido pagar ese peso en git. Los CSV agregados (`data/inputs_md/`) pesan poco, **se pueden
revisar en un diff** (si un indicador cambia, se ve exactamente en qué), y son lo único que
consumen los gráficos y el dashboard: es la frontera de trabajo entre el equipo de datos y el de
comunicación.

**Sale una onda nueva de la EPH: ¿qué corrés, y qué NO volvés a correr?**
Corrés `00_descarga_eph.R` (baja solo lo nuevo: `descargar_eph_incremental()` en
`utils_eph.R:21-53` saltea los `.rds` que ya existen, línea 31-34), después `01_limpieza_eph.R` y
los `02_indicadores_eph_*.R`. **No** hace falta re-descargar ni re-limpiar los 18 años anteriores:
por eso el pipeline está en tres etapas separadas y no en un solo script.

**¿Y si además agregaste una variable nueva a `vars_individuo`?**
Ahí la descarga incremental te traiciona: **no alcanza con sumarla al vector**. Como
`descargar_eph_incremental()` saltea cualquier `.rds` que ya exista en disco (`utils_eph.R:31-34`),
los trimestres ya descargados se quedan sin la columna nueva. Hay que borrar los `.rds` afectados
(`unlink(list.files("data/raw_data/eph/individuo", full.names = TRUE))`) y volver a correr `00`
entero. Es la causa nº 1 de "agregué la variable y me viene todo `NA`" (documentado también en
`cheatsheet_repo.md`, sección "Trampas conocidas").

---

## Las tres trampas, con su línea exacta

1. **La descarga incremental no re-descarga.** `src/utils_eph.R:31-34` (el `if (file.exists(out))
   { ...; next }` del loop). Ver la respuesta de arriba.

2. **El orden de `as.character()` en `limpiar_base_eph()`.** `src/utils_eph.R:76-86`, con el
   comentario in situ que explica por qué el orden importa. Es el bug más difícil de detectar del
   pipeline: no rompe nada, solo da todo mal, en silencio.

3. **El quiebre 2015/2016 de `PONDIIO`.** Se ve en tres lugares a la vez: la descarga tolerante
   (`vars_opcionales = c("PONDIIO")` en `00_descarga_eph.R:29`, reintento sin esa variable en
   `utils_eph.R:41-44`), el fallback en el cálculo de salarios (`peso_ing = if_else(!is.na(PONDIIO)
   & PONDIIO > 0, PONDIIO, PONDERA)`, `02_indicadores_eph_individuo.R:54`), y el hueco real en la
   serie (`13a_`/`13b_` tienen 71 trimestres en vez de 72 - verificalo con
   `read_csv("data/inputs_md/13a_nbi_hogares.csv") %>% distinct(fecha) %>% nrow()`).
