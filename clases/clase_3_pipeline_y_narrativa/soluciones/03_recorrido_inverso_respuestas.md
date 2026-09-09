# Solución · Práctica: recorrido inverso

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
