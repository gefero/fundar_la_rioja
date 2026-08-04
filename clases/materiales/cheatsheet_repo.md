# Cheatsheet — mantenimiento del repositorio

Referencia de una página para el equipo que mantiene el pipeline. Detalle completo en el
[README](../../README.md).

---

## Mapa del repositorio

```
src/                      El pipeline, en 3 etapas + un script de viz por indicador
  utils_eph.R             Funciones compartidas (descarga incremental, limpieza, región)
  00_descarga_eph.R       ETAPA 1 · microdatos crudos     → data/raw_data/eph/**/*.rds
  01_limpieza_eph.R       ETAPA 2 · datasets canónicos    → data/proc_data/eph_*.rds
  02_indicadores_eph_*.R  ETAPA 3 · indicadores agregados → data/inputs_md/*.csv
  03_prep_*, 05_prep_*    Prep de las fuentes SIPA (xlsx) → data/inputs_md/*.csv
  NN_<indicador>.R        Un script de visualización por indicador → outputs/plots/*.png
  999_run_pipeline.R      Corre todo de punta a punta

style/fundar_monitor_theme.R   Tema activo (el que usan todos los scripts de viz)
dashboard/                     App Shiny + sitio estático Quarto
data/inputs_md/*.csv           ← LO ÚNICO VERSIONADO de data/. La frontera con comunicación.
```

**Qué está en git y qué no:** `data/raw_data/` y `data/proc_data/` están en `.gitignore` (pesan
mucho y se regeneran). `data/inputs_md/*.csv` **sí** está versionado: es lo que consumen los
gráficos y el dashboard, y lo que se puede revisar en un diff.

---

## Las 3 etapas, y por qué están separadas

Cada etapa se puede correr sola. Así se recalcula un indicador sin volver a descargar ni relimpiar
23 años de microdatos.

| Etapa | Script | Lee | Escribe | Cuándo correrla |
|---|---|---|---|---|
| 1 | `00_descarga_eph.R` | INDEC (vía `eph::get_microdata()`) | `data/raw_data/eph/**/*.rds` | Salió una onda nueva, o agregaste una variable |
| 2 | `01_limpieza_eph.R` | los `.rds` crudos | `data/proc_data/eph_individuo.rds`, `eph_hogar.rds` | Cambió la descarga, o una variable derivada |
| 3 | `02_indicadores_eph_*.R` | los `.rds` canónicos | `data/inputs_md/*.csv` | Cambió un cálculo, o hay datos nuevos |
| 4 | `NN_<indicador>.R` | el CSV | `outputs/plots/*.png` | Cambió el dato o el diseño del gráfico |

---

## Tareas frecuentes

**Actualizar con una onda nueva de la EPH**

```r
source("src/00_descarga_eph.R")   # incremental: saltea lo que ya está en disco
source("src/01_limpieza_eph.R")
source("src/02_indicadores_eph_individuo.R")
source("src/02_indicadores_eph_hogar.R")
# después, los scripts de viz de los indicadores afectados
```

`descargar_eph_incremental()` va hasta el año en curso solo, sin editar el rango a mano. Si un
trimestre todavía no está publicado, avisa por consola y sigue con el resto.

**⚠️ Agregar una variable nueva de la EPH**

Sumarla a `vars_individuo` / `vars_hogar` en `00_descarga_eph.R` **no alcanza**: la descarga es
incremental y saltea los `.rds` que ya existen, así que los archivos viejos se quedan sin la
columna nueva.

```r
# 1. Agregar la variable a vars_individuo / vars_hogar en src/00_descarga_eph.R
# 2. BORRAR los .rds afectados:
unlink(list.files("data/raw_data/eph/individuo", full.names = TRUE))
# 3. Volver a correr la etapa 1 y las siguientes
```

**Recalcular un solo indicador** (sin tocar descarga ni limpieza)

```r
source("src/02_indicadores_eph_individuo.R")   # reescribe todos los CSV de individuo
source("src/04_desoc.R")                        # regenera el PNG
```

**Correr todo de punta a punta**

```r
source("src/999_run_pipeline.R")
```

**Ver el dashboard**

```r
shiny::runApp("dashboard")        # app interactiva
# quarto render dashboard/index.qmd   # sitio estático autocontenido
```

**Agregar un indicador al dashboard**

1. Que su CSV esté en `data/inputs_md/`.
2. Sumar una entrada a `INDICADORES` en `dashboard/R/data.R` (id, título, tópico, CSV, columna de
   valor, etiquetas, `shape`, `ylim`).
3. Listo: aparece solo en la app Shiny y en el sitio estático.

**Publicar**

Al pushear a `main` un cambio en `dashboard/`, `data/inputs_md/`, `style/` o el propio workflow, la
GitHub Action `.github/workflows/dashboard.yml` renderiza el sitio y lo publica en `gh-pages`.

---

## Trampas conocidas (pisadas y documentadas)

1. **La descarga incremental no re-descarga.** Ver arriba: hay que borrar los `.rds` a mano cuando
   se agrega una variable. Es la causa nº 1 de "agregué la variable y me viene todo NA".

2. **El orden de `as.character()` en `limpiar_base_eph()`.** Primero se castean a texto las columnas
   categóricas (sobre un objeto `labelled`, `as.character()` devuelve la *etiqueta*: `"Casa"`), y
   **recién después** se pela la clase `labelled` del resto. Al revés, `as.character()` devuelve el
   *código* (`"2"`) y todas las comparaciones de texto (`case_when`, `%in%`, `==`) dejan de matchear
   **en silencio, sin error**. Es el bug más difícil de detectar del pipeline.

3. **`PONDIIO` no existe antes de ~2016.** La EPH imputaba los ingresos y no publicaba el ponderador
   de ingreso. `descargar_eph_incremental()` reintenta la descarga sin las `vars_opcionales`, y el
   cálculo de salarios usa `PONDERA` como fallback. Consecuencia: **los niveles a ambos lados de
   2015/2016 no son comparables** (además la EPH estuvo interrumpida entre 2015-T3 y 2016-T1). Todo
   gráfico de salarios tiene que marcar ese quiebre.

4. **La Rioja es un dominio chico.** En un trimestre suelto, varias sub-dimensiones de NBI dan 0,00.
   No es que no haya privación: es que la muestra no alcanza. Promediar las cuatro ondas del año
   antes de comunicar un nivel.

---

## Funciones del tema (`style/fundar_monitor_theme.R`)

| Función | Para qué |
|---|---|
| `theme_monitor()` | Tema base: fondo beige, grilla horizontal, leyenda arriba |
| `theme_monitor_oscuro()` | Variante fondo oscuro (slides de KPIs) |
| `theme_monitor_barras_h()` | Variante para barras horizontales |
| `scale_color_fundar_multi()` / `scale_fill_fundar_multi()` | Escala para series múltiples |
| `scale_fill_fundar_div()` | Escala divergente verde/rosa |
| `fuente_fundar("EPH-INDEC")` | Caption con el formato `"Fuente: ..."` |
| `puntos_etiqueta(df, x, y, grupo)` | Devuelve máximo, mínimo y último de cada grupo, para etiquetar |
| `grafico_linea_monitor()` / `grafico_barras_div()` | Helpers de gráfico completo |

Colores: `FUNDAR_VERDE`, `FUNDAR_ROSA`, `FUNDAR_BEIGE`, `FUNDAR_GRIS`, `FUNDAR_OSCURO`, y la paleta
regional `FUNDAR_MULTI` (`serie_1` Resto país, `serie_2` NOA-Resto, `serie_3` La Rioja).
