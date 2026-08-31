# Catálogo de datos - Clase 3

Los 10 CSV de `data/inputs_md/` con los que se trabaja en el Bloque A ("Un gráfico desde cero").
Elegí uno antes de abrir RStudio: la pregunta que quieras contestar tiene que poder responderse con
las columnas que tiene.

Cada entrada trae lo mínimo para decidir sin tener que abrir el archivo primero: qué identifica una
fila, la granularidad, y **la advertencia metodológica que ese indicador necesita en el caption**
(ver `checklist_visualizacion.md` §3). Si tu CSV no está acá, no lo agarres para este ejercicio: no
está versionado o no tiene un script que lo produzca.

---

## `04_tasa_desoc.csv` - Tasa de desocupación

| | |
|---|---|
| **Fila = ** | fecha × región |
| **Columnas** | `fecha, la_rioja_region, desoc, pea, tasa_desoc` |
| **Granularidad** | Trimestral, 2007-Q1 a 2025-Q4 (72 trimestres) |
| **Unidades** | 3 regiones: `1. Resto país`, `2. NOA-Resto`, `3. La Rioja` |
| **Filas** | 216 = 72 × 3 |
| **Advertencia** | La Rioja es dominio chico de la EPH: no reportar un nivel a partir de un solo trimestre. |
| **Pregunta sugerida** | ¿La desocupación de La Rioja está por encima o por debajo del NOA y del resto del país, y desde cuándo? |

## `10_tasa_empleo.csv` - Tasa de empleo

| | |
|---|---|
| **Fila = ** | fecha × región |
| **Columnas** | `fecha, la_rioja_region, ocupado, pob_tot, tasa_empleo` |
| **Granularidad** | Trimestral, 2007-Q1 a 2025-Q4 (72 trimestres) |
| **Unidades** | 3 regiones |
| **Filas** | 216 |
| **Advertencia** | Dominio chico (ídem `04_`). |
| **Pregunta sugerida** | ¿Cuántos ocupados cada 100 habitantes hay en La Rioja, y esa cifra creció o bajó en la última década? |

## `09a_tasa_informalidad_aportes.csv` - Tasa de informalidad (aportes)

| | |
|---|---|
| **Fila = ** | fecha × región |
| **Columnas** | `fecha, la_rioja_region, formales, asalariados, tasa_inf_aportes` |
| **Granularidad** | Trimestral, 2007-Q1 a 2025-Q4 (72 trimestres) |
| **Unidades** | 3 regiones |
| **Filas** | 216 |
| **Advertencia** | Dominio chico. `tasa_inf_aportes` es `100 - (formales/asalariados × 100)`: universo de asalariados, no de ocupados totales. |
| **Pregunta sugerida** | ¿Qué región tiene mayor proporción de asalariados sin aportes ni descuentos jubilatorios? |

## `12_mayor_25_superior.csv` - % de +25 años con estudios superiores completos

| | |
|---|---|
| **Fila = ** | fecha × región |
| **Columnas** | `fecha, la_rioja_region, mayor_25_superior, pob_tot, porc_mayor_25_superior` |
| **Granularidad** | Trimestral, 2007-Q1 a 2025-Q4 (72 trimestres) |
| **Unidades** | 3 regiones |
| **Filas** | 216 |
| **Advertencia** | Dominio chico. |
| **Pregunta sugerida** | ¿Achicó o agrandó La Rioja la brecha educativa con el resto del país en estos 18 años? |

## `13a_nbi_hogares.csv` - % Hogares con NBI (total y 5 sub-dimensiones)

| | |
|---|---|
| **Fila = ** | fecha × región |
| **Columnas** | `fecha, la_rioja_region` + 6 conteos `hogares_NBI_{TOT,HAC,VIV,SAN,ESC,SUB}` + `hogares_base` + 6 `pct_hogares_NBI_*` |
| **Granularidad** | Trimestral, 2007-Q1 a 2025-Q4, **71 trimestres** (falta uno: el hueco 2015-T3/2016-T1) |
| **Unidades** | 3 regiones |
| **Filas** | 213 = 71 × 3 |
| **Advertencia** | Dominio chico, y acá se ve fuerte: en el último trimestre disponible, La Rioja da **0,00 %** en 4 de las 5 sub-dimensiones. No promediar 4 ondas antes de publicar un nivel es el error más fácil de cometer con este CSV. |
| **Pregunta sugerida** | ¿Qué privación explica la mayor parte del NBI de La Rioja? (Ya se usó en la Clase 2 con Cleveland dot plot - para este bloque, buscale una pregunta y una marca distintas: por ejemplo, la evolución del NBI total en el tiempo, o small multiples de las 5 sub-dimensiones.) |

## `13b_nbi_poblacion.csv` - % Población en hogares con NBI (espejo poblacional de `13a_`)

| | |
|---|---|
| **Fila = ** | fecha × región |
| **Columnas** | `fecha, la_rioja_region` + 6 conteos `pob_NBI_*` + `pob_base` + 6 `pct_pob_NBI_*` |
| **Granularidad** | Trimestral, 71 trimestres (mismo hueco que `13a_`) |
| **Unidades** | 3 regiones |
| **Filas** | 213 |
| **Advertencia** | Igual que `13a_`. Ojo con no mezclar las dos unidades de análisis (hogares vs. personas) en el mismo gráfico sin aclararlo. |
| **Pregunta sugerida** | ¿Cuánta gente vive en un hogar con NBI en La Rioja, contra cuántos hogares tienen NBI? (son números distintos - hogares con NBI tienden a tener más miembros). |

## `03b_salarios_registrados_EPH.csv` - Salario de asalariados registrados, por sector

| | |
|---|---|
| **Fila = ** | fecha × región × sector |
| **Columnas** | `fecha, la_rioja_region, sector, salario_promedio` |
| **Granularidad** | Trimestral, 2007-Q1 a 2025-Q4 (72 trimestres) |
| **Unidades** | 3 regiones × 2 sectores (Público/Privado) |
| **Filas** | 432 = 72 × 3 × 2 |
| **Advertencia** | **El quiebre 2015/2016**: el ponderador de ingreso `PONDIIO` no existe antes de esa fecha (fallback a `PONDERA`), y la EPH estuvo interrumpida entre 2015-T3 y 2016-T1. Los niveles a ambos lados no son estrictamente comparables. Además está en **pesos corrientes** (no deflactado). |
| **Pregunta sugerida** | ¿Cuál es la brecha entre el salario del sector público y el privado en La Rioja, y se achica o se agranda con el tiempo? |

## `03_salarios_privados_SIPA.csv` - Salario promedio del sector privado (SIPA)

| | |
|---|---|
| **Fila = ** | fecha × provincia |
| **Columnas** | `jurisdiccion, fecha, salario_promedio` |
| **Granularidad** | Mensual, 2015-01 a 2026-03 (135 meses) |
| **Unidades** | 24 provincias |
| **Filas** | 3.240 = 135 × 24 |
| **Advertencia** | **Pesos corrientes, no deflactado** - es el pendiente de mayor impacto sobre la calidad de lo publicado (`checklist_visualizacion.md` §3). Un gráfico de esta serie sin advertirlo muestra inflación, no el fenómeno. Cubre solo sector privado **registrado**. |
| **Pregunta sugerida** | ¿Cómo se ubica el salario privado de La Rioja contra el de las provincias vecinas del NOA? (Nota: en pesos corrientes, comparar entre provincias en un mismo momento es válido; comparar a través del tiempo, no.) |

## `05_puestos_asalariados_privados.csv` - Puestos asalariados privados

| | |
|---|---|
| **Fila = ** | fecha × provincia |
| **Columnas** | `jurisdiccion, fecha, puestos_miles` |
| **Granularidad** | Mensual, 2009-01 a 2026-03 (205 meses), serie desestacionalizada |
| **Unidades** | 24 provincias |
| **Filas** | 4.920 = 205 × 24 |
| **Advertencia** | Es un nivel (miles de puestos), no una tasa: una provincia grande siempre va a tener más puestos que La Rioja. Para comparar entre provincias hace falta normalizar (índice base 100, variación %). |
| **Pregunta sugerida** | ¿Cómo evolucionó el empleo privado de La Rioja en índice base 100 desde 2009, contra el total país? |

## `07_serie_empresas_por_jurisdiccion.csv` - Cantidad de empresas

| | |
|---|---|
| **Fila = ** | fecha × provincia |
| **Columnas** | `jurisdiccion, fecha, empresas` |
| **Granularidad** | Mensual, 2015-01 a 2026-03 (135 meses) |
| **Unidades** | 24 provincias |
| **Filas** | 3.240 = 135 × 24 |
| **Advertencia** | Igual que `05_`: es un nivel, no una tasa. Comparar niveles entre provincias de tamaño muy distinto necesita normalizar o dejarlo explícito en el título. |
| **Pregunta sugerida** | ¿Cuántas empresas hay en La Rioja hoy, y es más o menos que hace 5 años? |
| **Si elegís este para el Bloque B** | Este CSV es un caso especial para el rastreo: a diferencia de los otros nueve, **no tiene script de prep ni fuente cruda en el repo** (`src/07_cant_empresas.R` lo *lee*, no lo *escribe*). Es un hallazgo válido, no un error tuyo: documentalo así. |

---

## Cómo usar esta tabla

1. Elegí un CSV por la pregunta que te interese, no por el que ya conocés de las clases 1 y 2.
2. Mirá la advertencia: **va a aparecer en tu caption** (Paso 4 del Bloque A).
3. Si tu CSV tiene una unidad de análisis con más de 3 categorías (`05_`, `07_`, `03_`, con 24
   provincias), pensá si tu gráfico necesita mostrar las 24 o si conviene agrupar / destacar solo
   algunas (regla de la Clase 1: más de 12 colores no se distinguen).
