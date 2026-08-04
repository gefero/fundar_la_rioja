# Paso 5 — SOLUCIÓN: registrar el indicador en el dashboard

## La entrada a agregar

En `dashboard/R/data.R`, dentro de la lista `INDICADORES`. Conviene ponerla junto a los otros
indicadores de trabajo (después de `empleo`), para que quede agrupada en la pestaña:

```r
  actividad = list(
    id = "actividad", titulo = "Tasa de actividad",
    topico = "Trabajo e ingresos", csv = "06_tasa_actividad.csv",
    y_var = "tasa_actividad", y_lab = "PEA cada 100 hab. (%)",
    eje_x = "Año", caption = "EPH-INDEC", ylim = c(0, 55), shape = "A",
    desc = "Población económicamente activa (ocupados + desocupados) como % de la población total."
  ),
```

Y listo. **No hay que tocar `app.R` ni `index.qmd`.**

## Por qué alcanza con eso

Los dos front-ends —la app Shiny y el sitio estático de Quarto— leen el mismo registro y llaman a la
misma función de graficado, `plot_indicador()` en `dashboard/R/plots.R`. El registro es la única
fuente de verdad:

```
dashboard/R/data.R  ──►  INDICADORES + cargar_indicador()
                                │
                                ▼
dashboard/R/plots.R ──►  plot_indicador()
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
              app.R (Shiny)          index.qmd (estático)
```

Por eso el dashboard "sabe" dibujar un indicador que nunca vio: no hay código específico por
indicador, hay un registro de metadatos y una función genérica.

## Campo por campo

| Campo | Qué es | Por qué este valor |
|---|---|---|
| `id` | Clave interna | Tiene que coincidir con el nombre del elemento de la lista |
| `titulo` | Lo que se ve en el selector | Corto: acá sí va el nombre de la variable, no el hallazgo |
| `topico` | Agrupa las pestañas | **Tiene que ser uno de los tres de `TOPICOS`**, si no, no aparece |
| `csv` | Nombre del archivo | Solo el nombre; la ruta la resuelve `DATA_DIR` |
| `y_var` | Columna del valor | Tiene que existir en el CSV, escrita igual |
| `y_lab` | Título del eje Y | Con la unidad |
| `ylim` | Rango del eje | `c(0, 55)` porque la serie va de 39 a 49 y el eje arranca en cero |
| `shape` | Forma del CSV | `"A"`: serie trimestral regional, una fila por fecha-región |
| `desc` | Texto explicativo | Se muestra bajo el gráfico. Definición operativa, no interpretación |

### Sobre `shape`

Es lo que le dice a `cargar_indicador()` cómo normalizar el CSV:

- **`"A"`** — serie trimestral regional de la EPH: columnas `fecha` (`"2007-Q1"`),
  `la_rioja_region` y la columna de valor. **Es nuestro caso.**
- **`"B"`** — serie mensual provincial (SIPA/SRT): columnas `jurisdiccion`, `fecha` (Date) y valor.
  El loader clasifica cada provincia en región y promedia.
- **`"C"`** — trimestral regional con dos series por sector (público/privado). Se facetea por región.

Si el `shape` está mal, el gráfico sale vacío o el loader falla al no encontrar las columnas que
espera.

## Verificar

```r
shiny::runApp("dashboard")
```

El indicador tiene que aparecer en el selector, bajo "Trabajo e ingresos", con sus filtros de región
y rango temporal, la descarga de PNG y CSV, y el switch de gráfico interactivo.

Para el sitio estático:

```bash
quarto render dashboard/index.qmd
```

## Si no aparece

Revisar en este orden, que es el de las causas más frecuentes:

1. **El `topico` no es uno de los tres de `TOPICOS`.** Un typo o un acento distinto y el indicador
   queda fuera de todas las pestañas, sin error.
2. **El nombre del CSV no coincide** con el archivo real en `data/inputs_md/`.
3. **`y_var` no coincide** con el nombre de la columna en el CSV. Verificalo con
   `names(read_csv("data/inputs_md/06_tasa_actividad.csv"))`.
4. **Falta la coma** al cerrar la entrada anterior de la lista. R te lo dice, pero el mensaje de
   error de una lista mal formada es poco claro.

## La pregunta del paso 6

> El workflow `.github/workflows/dashboard.yml` se dispara con cambios en `data/inputs_md/`.
> ¿Se disparó con este push?

**No.** El workflow escucha `on: push: branches: [main]`. Al pushear a la rama `tasa-actividad` no
se dispara: recién corre cuando el Pull Request se mergea a `main`.

Es intencional, y es la razón de trabajar con ramas: **el push a `main` publica**. Si cada rama de
trabajo republicara el sitio, cualquier prueba a medio hacer saldría al aire. La rama y el PR son el
paso de revisión que separa "estoy probando" de "esto está publicado".
