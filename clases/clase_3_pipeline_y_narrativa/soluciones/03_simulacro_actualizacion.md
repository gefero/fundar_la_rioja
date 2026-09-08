# Solución · Práctica Parte 2: simulacro de actualización + recorrido inverso

---

## a) Simulacro de actualización *(sin descargar microdatos)*

La idea es ver el **último eslabón** funcionando en aislamiento: cambiar el CSV, correr el script de
viz, ver el PNG, revertir. Es exactamente lo que pasa cuando sale una onda nueva de la EPH, salvo
que acá la fila la ponemos a mano en vez de que la calcule `02_indicadores_eph_individuo.R`.

### Paso a paso

1. Abrir `data/inputs_md/04_tasa_desoc.csv`. Mirar la última fecha (`2025-Q1` o la que haya) y las
   tres filas regionales de ese trimestre.

2. Agregar al final del archivo tres filas ficticias para `2026-Q2` (copiar los valores del último
   trimestre y cambiarlos un poco). Las columnas son `fecha,la_rioja_region,desoc,pea,tasa_desoc`:

   ```csv
   2026-Q2,1. Resto país,900000,13500000,6.7
   2026-Q2,2. NOA-Resto,80000,1350000,5.9
   2026-Q2,3. La Rioja,6500,95000,6.8
   ```

   > Los valores de `desoc` y `pea` no tienen que ser exactos: el script de viz solo grafica
   > `tasa_desoc`. Pero conviene que `tasa_desoc ≈ desoc / pea * 100` para que el CSV sea coherente
   > (esa coherencia es lo que revisa un PR).

3. Correr el script de visualización, desde la raíz del repo:

   ```r
   source("src/04_desoc.R")
   ```

4. Abrir `outputs/plots/04_desoc.png`. La serie ahora llega hasta 2026-Q2: las tres líneas tienen
   un tramo más a la derecha.

5. **Revertir todo con git** (la parte importante del ejercicio):

   ```bash
   git checkout data/inputs_md/04_tasa_desoc.csv
   git checkout outputs/plots/04_desoc.png     # si lo querés dejar como estaba
   ```

   El CSV vuelve exactamente a como estaba. `git` es la red: se puede experimentar sin miedo
   porque cualquier cambio en un archivo versionado se deshace con un comando.

### Qué deja el ejercicio

- **La etapa de viz es barata y determinística.** Correr `src/04_desoc.R` tarda un segundo y
  siempre produce el mismo PNG a partir del mismo CSV. Toda la lentitud del pipeline está arriba
  (descarga + limpieza).
- **El CSV es el contrato.** Si tiene las columnas correctas y datos coherentes, el gráfico sale.
  El script de viz no sabe ni le importa de dónde vino la fila.
- **En un flujo real** esa fila no se escribe a mano: la calcula `02_indicadores_eph_individuo.R`
  después de `00` (descarga) y `01` (limpieza). El simulacro salta esas dos etapas para mostrar la
  última en aislamiento.

### Variante: el mismo simulacro con el bump

Agregar un año ficticio (`2025`) a `data/inputs_md/15_pbg_per_capita_por_provincia.csv` —24 filas,
una por provincia— y volver a correr `soluciones/02_bump_pbg.R`. El `min_rank()` recalcula el
ranking de ese año solo; si a La Rioja le ponés un `pbg_per_capita` alto, su línea "sube" en el
gráfico. Revertir igual con `git checkout`.

---

## b) Recorrido inverso

Para cada número, la cadena completa desde el gráfico publicado hasta la fuente cruda.

### 1. "La tasa de desocupación de La Rioja fue de X% en el último trimestre" (`outputs/plots/04_desoc.png`)

| Eslabón | Dónde |
|---|---|
| Lo dibuja | `src/04_desoc.R`, `geom_line()` sobre la columna `tasa_desoc` |
| El número está en | `data/inputs_md/04_tasa_desoc.csv`, columna `tasa_desoc`, fila `fecha == "2025-Q1"` (o la última) y `la_rioja_region == "3. La Rioja"` |
| Lo calcula | `src/02_indicadores_eph_individuo.R`, bloque "04": `sum(desocupado * PONDERA) / sum(pea * PONDERA) * 100`, agrupado por `fecha` y `la_rioja_region` |
| De dónde salen `desocupado` y `pea` | `src/01_limpieza_eph.R`: se derivan de `ESTADO` (`desocupado = ESTADO == "Desocupado"`, `pea = ESTADO %in% c("Ocupado","Desocupado")`) |
| De dónde sale `ESTADO` | Columna cruda de la EPH, descargada por `src/00_descarga_eph.R` → `data/raw_data/eph/individuo/2025_1_EPH_individuo.rds` |
| Fuente última | EPH continua, INDEC, vía el paquete `eph` (`eph::get_microdata()`) |

### 2. "El X% de los hogares de La Rioja tiene alguna Necesidad Básica Insatisfecha" (`outputs/plots/13a_nbi_hogares.png`)

| Eslabón | Dónde |
|---|---|
| Lo dibuja | `src/13a_nbi_hogares.R`, columna `pct_hogares_NBI_TOT` |
| El número está en | `data/inputs_md/13a_nbi_hogares.csv`, columna `pct_hogares_NBI_TOT` |
| Lo calcula | `src/02_indicadores_eph_hogar.R`: `sum(NBI_TOT * PONDERA) / sum(PONDERA) * 100`. **Este script cruza hogar con individuo** (para `NBI_ESC` y `NBI_SUB` necesita datos de las personas del hogar) |
| De dónde sale `NBI_TOT` | Es "al menos uno de": `NBI_HAC`, `NBI_VIV`, `NBI_SAN` (calculados en `src/01_limpieza_eph.R` desde `IX_TOT`/`II1`, `IV1`, `IV8`/`IV11`) + `NBI_ESC`, `NBI_SUB` (calculados en el propio `02_indicadores_eph_hogar.R`, cruzando con `CH06`/`CH10`/`CH12` de individuo) |
| Fuente última | EPH continua (bases de **hogar** e **individuo**), INDEC |

> Detalle para el caption: las sub-dimensiones de NBI en La Rioja tienen mucho ruido muestral. Ver
> `guion.md`, "las cuatro trampas", nº 4.

### 3. "El salario promedio del sector privado registrado en La Rioja fue de $X" (`outputs/plots/03_salarios_privados_SIPA.png`)

| Eslabón | Dónde |
|---|---|
| Lo dibuja | `src/03_salarios_privados_SIPA.R`, columna `salario_promedio` (promediada por región) |
| El número está en | `data/inputs_md/03_salarios_privados_SIPA.csv`, columna `salario_promedio`, por `jurisdiccion` y `fecha` |
| Lo prepara | `src/03_prep_salarios_privados_SIPA.R`: pivotea la hoja (viene traspuesta), parsea el encabezado de fechas, homologa nombres de provincia, recorta desde 2015 |
| Fuente cruda | `data/raw_data/sipa/provinciales_serie_remuneraciones_mensual_2dig_8.xlsx`, hoja **"Total"** |
| Fuente última | SIPA — "Trabajo registrado", Ministerio de Capital Humano. **No es EPH:** es otra fuente, con su propio `prep` y sin las etapas de descarga/limpieza de microdatos |

**La diferencia clave entre el caso 3 y los casos 1–2:** el salario SIPA no pasa por
`00_descarga_eph.R` ni `01_limpieza_eph.R` ni `02_indicadores_*.R`. Es un Excel que se descarga a
mano, se reemplaza en `data/raw_data/sipa/` cuando sale la actualización mensual, y un único script
`03_prep_*` lo convierte en CSV. Ver el diagrama del `guion.md`: la columna de la derecha.
