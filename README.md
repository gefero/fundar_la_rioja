# Fundar – Monitor Socioeconómico La Rioja

Repositorio de código para el procesamiento y visualización de indicadores socioeconómicos del Gobierno de La Rioja, desarrollado por [Fundar](https://fund.ar/) / CFI – Grupo factor~data.

## Objetivo

Generar un pipeline replicable que permita calcular y visualizar una serie de indicadores clave a partir de microdatos públicos. Los indicadores se organizan en torno a tres ejes temáticos: **trabajo e ingresos**, **desarrollo** y **macroeconomía**.

## Indicadores

| # | Indicador | Tópico | Fuente | Estado |
|---|---|---|---|---|
| 04 | Tasa de desempleo (% de la PEA) | Trabajo – Informalidad y Desempleo | EPH | ✓ |
| 09a | Tasa de informalidad por aportes a SS (% de asalariados) | Trabajo – Informalidad y Desempleo | EPH | ✓ |
| 10 | Tasa de empleo (ocupados cada 100 hab.) | Trabajo – Participación laboral | EPH | ✓ |
| 12 | % de población +25 con estudios superiores completos | Desarrollo – Educación | EPH | ✓ |
| — | Salarios en el sector formal (público y privado) | Trabajo – Salarios e ingresos | — | Pendiente |
| — | Puestos de trabajo asalariados formales privados totales | Trabajo – Salarios e ingresos | — | Pendiente |
| — | Cantidad de empleados públicos cada 1.000 hab. | Trabajo – Salarios e ingresos | — | Pendiente |
| — | Tasa de pobreza multidimensional | Desarrollo – Pobreza | — | Pendiente |
| — | Trayectoria escolar | Desarrollo – Educación | — | Pendiente |
| — | PIB provincial | Macroeconomía – Crecimiento | — | Pendiente |
| — | % del PIB que es industrial | Macroeconomía – Crecimiento | — | Pendiente |
| — | Cantidad de empresas | Macroeconomía – Crecimiento | — | Pendiente |
| — | Exportaciones | Macroeconomía – Crecimiento | — | Pendiente |
| — | Resultado fiscal (ingreso total – gasto total) | Macroeconomía – Crecimiento | — | Pendiente |
| — | Recursos propios sobre recursos totales | Macroeconomía – Crecimiento | — | Pendiente |

## Estructura del repositorio

```
fundar_la_rioja/
├── src/
│   ├── 00_preproc_EPH.R          # Descarga, procesamiento y generación de agregados
│   ├── 04_desoc.R                # Visualización: tasa de desocupación
│   ├── 09a_informalidad_aportes.R # Visualización: tasa de informalidad (aportes)
│   ├── 10_tasa_empleo.R          # Visualización: tasa de empleo
│   └── 12_educ.R                 # Visualización: % población +25 con estudios superiores
├── data/
│   ├── raw_data/                 # Microdatos EPH por año y trimestre (*.rds)
│   └── inputs_md/                # Agregados por indicador listos para graficar (*.csv)
├── style/
│   ├── fundar_larioja_theme.R    # Tema original (paleta La Rioja / NOA / Resto país)
│   └── fundar_monitor_theme.R    # Tema inspirado en el Monitor Mensual de Empresas de Fundar
└── fundar_larioja.Rproj          # Proyecto RStudio
```

> Los archivos en `data/raw_data/` y el dataset procesado `data/proc_data_eph.rds` están excluidos del control de versiones (`.gitignore`). Los CSVs en `data/inputs_md/` sí están versionados.

## Pipeline de datos (EPH)

El flujo de trabajo se ejecuta íntegramente desde `src/00_preproc_EPH.R`:

### 1. Descarga incremental

Itera sobre todos los años (2007–2025) y trimestres (1–4) y descarga los microdatos individuales de la EPH usando `eph::get_microdata()`. Cada trimestre se guarda como un `.rds` separado en `data/raw_data/`. Si el archivo ya existe, se omite la descarga.

### 2. Carga y unión

Lee todos los `.rds` de `data/raw_data/` y los une en un único dataframe.

### 3. Preprocesamiento

Construye las variables analíticas necesarias sobre el dataframe unificado:

- **Laborales**: `ocupado`, `desocupado`, `pea`, `no_pea`
- **Educativas**: `niv_educ_sup`, `mayor_25`, `mayor_25_superior`
- **Informalidad**: `tamanio_estab` (tamaño del establecimiento), `descuento`, `aporta`, `aportes_descuentos`, `asalariado_ocupado`
- **Geográficas**: `la_rioja_region` — clasifica cada aglomerado en tres grupos:
  - `1. Resto país`
  - `2. NOA-Resto`
  - `3. La Rioja` *(énfasis visual)*

### 4. Generación de agregados

Calcula los indicadores agrupando por `fecha`, `REGION`, `AGLOMERADO` y `la_rioja_region`, y guarda cada uno como CSV en `data/inputs_md/`:

| Archivo CSV | Indicador | Variable clave |
|---|---|---|
| `04_tasa_desoc.csv` | Tasa de desocupación | `tasa_desoc` |
| `09a_tasa_informalidad_aportes.csv` | Tasa de informalidad (aportes) | `tasa_inf_aportes` |
| `10_tasa_empleo.csv` | Tasa de empleo | `tasa_empleo` |
| `12_mayor_25_superior.csv` | % población +25 con estudios superiores | `porc_mayor_25_superior` |

### 5. Visualización

Cada script `src/XX_*.R` lee su CSV correspondiente y genera un gráfico de líneas con `ggplot2`, usando las escalas definidas en `style/fundar_monitor_theme.R`.

## Sistema de estilos

El proyecto cuenta con dos archivos de estilo en `style/`:

### `fundar_larioja_theme.R` (tema original)

- **`scale_color_larioja()`** / **`scale_fill_larioja()`**: paleta regional (gris para Resto país, azul para NOA-Resto, naranja para La Rioja).
- **`scale_linewidth_larioja()`**: grosor de línea diferenciado por región.
- **`theme_larioja()`**: tema minimalista con tipografía y márgenes estandarizados.
- **`theme_larioja_mapa()`**: variante sin ejes ni grilla para cartografía.
- **`grafico_lineas_regional()`**: helper para gráficos de líneas regionales.
- **`PALETA_CONTINUA`**: gradiente azul → blanco → naranja para variables continuas.

### `fundar_monitor_theme.R` (tema activo — Monitor Mensual de Empresas)

Replica el estilo visual del [Monitor Mensual de Empresas](https://fund.ar/publicacion/monitor-mensual-de-empresas/) de Fundar. Es el tema usado por todos los scripts de visualización.

**Paleta de colores:**

| Variable | Color | Uso |
|---|---|---|
| `FUNDAR_VERDE` | `#52C8A0` | Verde menta — color principal / positivo |
| `FUNDAR_ROSA` | `#F4877A` | Rosa salmón — negativo / caídas |
| `FUNDAR_BEIGE` | `#EDE8E0` | Fondo del área del gráfico |
| `FUNDAR_OSCURO` | `#1C1C1C` | Fondo oscuro para slides de KPIs |

**Asignación regional:**

| Región | Color |
|---|---|
| `1. Resto país` | `#A8DCC8` (verde menta claro) |
| `2. NOA-Resto` | `#C8C87A` (amarillo oliva) |
| `3. La Rioja` | `#2D6E6E` (verde azulado oscuro — énfasis) |

**Componentes:**

- **`theme_fundar()`**: tema base con fondo beige, grilla horizontal suave, leyenda arriba, etiquetas del eje X a 45°.
- **`theme_fundar_oscuro()`**: variante con fondo oscuro.
- **`theme_fundar_barras_h()`**: variante para gráficos de barras horizontales.
- **`scale_color_fundar_multi()`** / **`scale_fill_fundar_multi()`**: escala de color para series múltiples.
- **`scale_fill_fundar_div()`**: escala verde/rosa para gráficos divergentes.
- **`fuente_fundar()`**: helper para el caption en formato `"Fuente: ..."`.
- **`grafico_lineas_monitor()`**: helper para gráfico de línea única estilo Monitor.
- **`grafico_barras_div()`**: helper para barras horizontales divergentes con etiquetas.

Los prefijos numéricos en la clasificación regional garantizan que ggplot dibuje La Rioja por encima del resto sin transformaciones adicionales.

## Dependencias

```r
install.packages(c("eph", "tidyverse", "lubridate", "tictoc"))
```

| Paquete | Uso |
|---|---|
| `eph` | Descarga de microdatos de la EPH (INDEC) |
| `tidyverse` | Manipulación de datos y visualización (`dplyr`, `ggplot2`, `readr`) |
| `lubridate` | Manejo de fechas |
| `tictoc` | Medición de tiempos en la descarga |

## Cómo reproducir

```r
# 1. Descargar microdatos, procesar y generar CSVs de indicadores (una sola vez)
source("src/00_preproc_EPH.R")

# 2. Generar visualizaciones por indicador
source("src/04_desoc.R")                # Tasa de desocupación
source("src/09a_informalidad_aportes.R") # Tasa de informalidad
source("src/10_tasa_empleo.R")           # Tasa de empleo
source("src/12_educ.R")                  # Educación superior
```

> La descarga completa (2007–2025) puede tomar varios minutos. El script es incremental: si se interrumpe, retoma desde el último archivo faltante.

## Contexto del proyecto

Este repositorio corresponde al **Componente 3** de un proyecto más amplio con el Gobierno de La Rioja. El trabajo se organiza en tres etapas:

1. **Coordinación y definición de indicadores**: alineación con los demás componentes del proyecto.
2. **Diseño de maquetas**: definición del tipo de gráfico, paleta de colores y jerarquía visual para cada indicador. El código se desarrolla en R con `ggplot2` como base, incorporando `plotly` cuando se requieren versiones interactivas.
3. **Materiales para talleres de visualización de datos**.
