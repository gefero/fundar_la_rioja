# Clase 3 - Del microdato al producto: pipeline, actualización y narrativa

**Duración:** 120 minutos · **Teoría y demo:** 55' · **Práctica integradora:** 50' · **Cierre:** 10'

**Material de slides:** todas nuevas (~10). **Material de apoyo:**
[`cheatsheet_repo.md`](../materiales/cheatsheet_repo.md) y
[`checklist_visualizacion.md`](../materiales/checklist_visualizacion.md), impresos.

**Objetivo de la clase:** cerrar el circuito. Las clases 1 y 2 fueron sobre el gráfico; esta es sobre
todo lo que hay antes y después: de dónde salen los datos, cómo se actualizan, cómo se les pone
narrativa y cómo se publican.

Es la clase donde los dos perfiles hacen cosas distintas pero acopladas. Conviene decirlo al
arrancar: **nadie se va a aburrir en la mitad que no le toca**, porque la práctica final los obliga
a trabajar juntos.

---

## 0–25' · Anatomía del pipeline

**Foco:** perfil mantenimiento. **Slides nuevas: 3.**

### El diagrama (una slide, la más importante de la clase)

```
   INDEC / SIPA
        │
        ▼
┌─────────────────────┐
│ 00_descarga_eph.R   │  ETAPA 1 · descarga incremental
└─────────────────────┘  → data/raw_data/eph/**/*.rds     [NO versionado]
        │
        ▼
┌─────────────────────┐
│ 01_limpieza_eph.R   │  ETAPA 2 · limpieza y canonización
└─────────────────────┘  → data/proc_data/eph_*.rds       [NO versionado]
        │
        ▼
┌─────────────────────┐
│ 02_indicadores_*.R  │  ETAPA 3 · cálculo de indicadores
└─────────────────────┘  → data/inputs_md/*.csv           [★ VERSIONADO ★]
        │
        ├──────────────────────┬─────────────────────┐
        ▼                      ▼                     ▼
   src/NN_*.R             dashboard/           informes, placas,
   → outputs/plots/       app.R + index.qmd    presentaciones
```

**Las tres cosas que hay que explicar de este diagrama:**

1. **Por qué tres etapas y no un script.** Para poder re-ejecutar solo una parte. Recalcular un
   indicador no requiere volver a descargar ni relimpiar 19 años de microdatos. La descarga completa
   tarda varios minutos; el cálculo de indicadores, segundos.

2. **Por qué `data/raw_data/` está en `.gitignore` y `data/inputs_md/` no.** Los microdatos pesan
   mucho, se regeneran solos y no tiene sentido versionarlos. Los CSV agregados pesan poco, **se
   pueden revisar en un diff** (si un indicador cambia, se ve exactamente en qué), y son lo que
   consumen los gráficos y el dashboard.

3. **La línea con la estrella es la frontera del taller.** Es la misma que presentamos en la clase 1.
   Todo lo que está arriba es responsabilidad del equipo de datos; todo lo que está abajo, del de
   comunicación. El contrato es el CSV: si tiene las columnas esperadas y los datos correctos, las
   dos mitades pueden trabajar en paralelo sin pisarse.

### Demo en vivo (10')

Abrir `src/00_descarga_eph.R` y `src/utils_eph.R` en paralelo, y mostrar:

```r
# Bajar UN trimestre, para ver el mecanismo (no la serie completa: tarda).
library(eph)
df <- get_microdata(year = 2025, period = 2, type = "individual",
                    vars = c("ANO4","TRIMESTRE","AGLOMERADO","ESTADO","PONDERA"))
dim(df)
head(df$ESTADO)   # ¡ojo! viene como códigos numéricos con etiquetas pegadas
```

Los puntos a mostrar:

- **`descargar_eph_incremental()` saltea lo que ya está en disco.** Correrla dos veces no vuelve a
  bajar nada. Por eso re-ejecutar el pipeline es barato.
- **Es tolerante a fallas:** si un trimestre todavía no está publicado, avisa por consola y sigue.
  No corta el loop ni pierde lo ya descargado.
- **`organize_labels()`** convierte los códigos en etiquetas legibles. Mostrar el antes y el después:
  `ESTADO` pasa de `1` a `"Ocupado"`, y ahí recién funciona el `if_else(ESTADO == "Ocupado", 1, 0)`
  de `01_limpieza_eph.R`.

Después mostrar el otro extremo: correr `02_indicadores_eph_individuo.R` y ver el CSV cambiar.

### Las tres trampas (una slide, para dejar pegada al monitor)

Están todas documentadas en el README y en los comentarios del código, y las tres ya se pisaron:

1. **La descarga incremental no re-descarga.** Si agregás una variable a `vars_individuo`, los
   `.rds` que ya existen **no** se actualizan: el paso saltea archivos existentes. Hay que
   **borrarlos** y volver a correr `00`. Es la causa nº 1 de "agregué la variable y me viene todo
   `NA`".

2. **El orden de `as.character()` en `limpiar_base_eph()`.** Primero se castean a texto las columnas
   categóricas (sobre un objeto `labelled`, `as.character()` devuelve la **etiqueta** (`"Casa"`)) y
   **recién después** se pela la clase `labelled` del resto. Al revés, `as.character()` devuelve el
   **código** (`"2"`), y todas las comparaciones de texto (`case_when`, `%in%`, `==`) dejan de
   matchear **en silencio, sin error ni warning**. Es el bug más difícil de detectar del pipeline:
   no rompe nada, solo te da todo mal.

3. **El quiebre 2015/2016.** `PONDIIO` no existe antes de ~2016 (la EPH imputaba los ingresos y no
   publicaba el ponderador de ingreso), así que el cálculo de salarios usa `PONDERA` como fallback.
   Consecuencia: **los niveles a ambos lados no son comparables**, y encima la EPH estuvo
   interrumpida entre 2015-T3 y 2016-T1. Todo gráfico de salarios tiene que marcar el quiebre.

**Para el perfil comunicación**, la trampa 3 no es un detalle técnico: es exactamente el tipo de cosa
que tiene que aparecer en el caption de un gráfico publicado. Sirve de puente al bloque siguiente.

---

## 25–45' · Narrativa y visualización

**Foco:** perfil comunicación. **Slides nuevas: 3.** Fuente:
[`Informe_final_argendata.pdf`](../materiales/Informe_final_argendata.pdf), págs. 40–42.

### La regla de fondo

> El gráfico es **soporte de una narrativa**. Si el texto habla de cuatro rubros, no muestres doce.
> **La granularidad del gráfico tiene que igualar la del texto.**

El informe lo muestra con el caso ENGHo: el análisis publicado en Argendata solo menciona cuatro
rubros de consumo, pero el gráfico desagrega doce. La solución no es hacer un gráfico más lindo: es
**desagregar solo lo que el texto discute** y agregar el resto.

### Los tres campos de texto de un gráfico

Esto es concreto y aplicable de inmediato. Ir a `src/04_desoc.R` y mirar el `labs()`:

```r
labs(title   = "Tasa de desocupación",       # ← nombra la variable
     x       = "Año-Trimestre",
     y       = "Tasa de desocupación (%)",
     caption = fuente_fundar("EPH-INDEC"))
```

Está bien para un script de trabajo, y **mal para publicar**. La versión publicable:

| Campo | Qué tiene que decir | Ejemplo |
|---|---|---|
| **Título** | **El hallazgo, afirmado.** Una oración que se pueda leer sola. | "La desocupación en La Rioja se ubica por debajo del promedio del NOA desde 2021" |
| **Subtítulo** | Unidad, universo, período, y cualquier transformación aplicada | "Desocupados como % de la PEA. Aglomerado La Rioja, 2007–2025, trimestral." |
| **Caption** | Fuente completa **y las advertencias metodológicas** | "Fuente: Fundar, con base en la EPH (INDEC). Serie interrumpida entre 2015-T3 y 2016-T1." |

El ejercicio para hacer con la sala: proyectar tres PNG de `outputs/plots/` y **reescribir los
títulos entre todos**. Es rápido y deja el punto clavado.

### El mejor y el peor ejemplo, los dos del repo

- **El mejor:** `src/03b_salarios_registrados_EPH.R`. Su caption dice explícitamente *"Línea
  punteada: cambio de metodología de ingresos de la EPH (2015-2016); niveles a ambos lados no
  estrictamente comparables"*, y el gráfico dibuja esa línea. El lector tiene lo que necesita para
  no sacar una conclusión falsa.
- **El peor:** el título de `04_desoc.R` es el nombre de la variable, y no dice nada. Cualquiera de
  los diez indicadores tiene el mismo problema.

Cerrar con la advertencia muestral, que es específica de este proyecto y ya apareció en la clase 2:

> **La Rioja es un dominio chico de la EPH.** Nunca reportar un nivel a partir de un solo trimestre:
> promediar las cuatro ondas del año. Y un `0,00` en una sub-dimensión de NBI **no significa "no hay
> privación"**, significa "la muestra no alcanza para medirlo". Si se publica, hay que decirlo.

---

## 45–55' · El circuito de publicación

**Para todos.** **Slides nuevas: 2.**

Cómo un indicador llega a estar publicado, en tres pasos:

**1. El gráfico estático.** Un script `src/NN_<indicador>.R` que lee su CSV y escribe un PNG en
`outputs/plots/`. Es el patrón de los diez indicadores existentes: 20 líneas, todas iguales.

**2. El dashboard.** No hay que tocar código de la app: alcanza con **registrar el indicador** en
`INDICADORES`, en `dashboard/R/data.R`. Mostrar una entrada real:

```r
desocupacion = list(
  id = "desocupacion", titulo = "Tasa de desocupación",
  topico = "Trabajo e ingresos", csv = "04_tasa_desoc.csv",
  y_var = "tasa_desoc", y_lab = "Tasa de desocupación (%)",
  eje_x = "Año", caption = "EPH-INDEC", ylim = c(0, 20), shape = "A",
  desc = "Desocupados como % de la Población Económicamente Activa (PEA)."
)
```

Con eso el indicador **aparece solo** en la app Shiny y en el sitio estático, porque los dos
front-ends leen el mismo registro y usan la misma función de graficado (`plot_indicador()` en
`dashboard/R/plots.R`). El `shape` dice qué forma tiene el CSV: `"A"` serie trimestral regional,
`"B"` serie mensual provincial, `"C"` trimestral con dos series por sector.

**3. La publicación.** El workflow `.github/workflows/dashboard.yml` se dispara al pushear a `main`
un cambio en `dashboard/`, `data/inputs_md/`, `style/` o el propio workflow: renderiza el Quarto y
lo publica en `gh-pages`. **Actualizar un CSV republica el sitio solo.**

**El flujo de git**, para quien no lo tenga incorporado:

```bash
git checkout -b mi-cambio      # nunca trabajar directo sobre main
git add src/ data/inputs_md/
git commit -m "Agrego indicador de tasa de actividad"
git push -u origin mi-cambio
# → abrir un Pull Request en GitHub
```

Por qué una rama y un PR: porque el push a `main` **publica**. La rama permite que otro mire el
cambio antes de que salga.

---

## 55–60' · Pausa

---

## 60–110' · Práctica integradora

Consigna completa en [`practica.md`](practica.md).

**Un solo ejercicio, en parejas de perfiles mezclados: agregar un indicador nuevo al monitor.**

El indicador es la **tasa de actividad** (PEA sobre población total), que hoy no existe en el
proyecto y se puede derivar de dos CSV ya versionados: `04_tasa_desoc.csv` aporta la `pea` y
`10_tasa_empleo.csv` aporta la `pob_tot`.

Es un recorrido completo del circuito, en cinco pasos:

| Paso | Quién | Qué |
|---|---|---|
| 1 | mantenimiento | `src/06_prep_tasa_actividad.R`: join → `data/inputs_md/06_tasa_actividad.csv` |
| 2 | los dos | Verificar el resultado: 216 filas, y la relación actividad ≈ empleo + desocupados |
| 3 | comunicación | Redactar título, subtítulo y caption según el bloque de las 25–45' |
| 4 | mantenimiento | `src/06_tasa_actividad.R`: el gráfico, siguiendo el patrón de `04_desoc.R` |
| 5 | los dos | Registrar en `INDICADORES` y verlo aparecer en `shiny::runApp("dashboard")` |
| 6 | los dos | Rama, commit, push |

**Variante avanzada**, para quien tenga los microdatos descargados: calcular la tasa directamente
desde el canónico en `02_indicadores_eph_individuo.R` (las variables `pea` y `PONDERA` ya están) y
**contrastar los dos resultados**. Tienen que dar igual - y si no dan igual, encontrar por qué es el
mejor ejercicio de todo el taller.

**Cómo conducirla.** Los pasos 1 y 4 tienen scripts con `TODO`. El paso 5 es el momento *wow*: ver el
indicador propio aparecer en el dashboard sin haber tocado la app. Dejar tiempo para eso.

Si alguna pareja va rápido, el paso 6 (rama y PR) es lo que conviene que hagan bien, porque es lo que
van a repetir cada vez.

---

## 110–120' · Cierre

### El mapa de pendientes del repositorio

Cerrar el taller con trabajo real. Estos son los pendientes concretos, y conviene salir con nombres
asignados:

**Indicadores sin implementar** (marcados "Pendiente" en el README):

- Cantidad de empleados públicos cada 1.000 hab.
- Tasa de pobreza multidimensional · Trayectoria escolar
- PIB provincial · % del PIB que es industrial · Exportaciones
- Resultado fiscal · Recursos propios sobre recursos totales

**Deuda técnica identificada durante el taller:**

- **El indicador 03 está en pesos corrientes** (clase 2). Requiere sumar una serie de IPC al
  repositorio para deflactar. Es el pendiente de mayor impacto sobre la calidad de lo publicado.
- **Los ejes X tienen 72 marcas de texto** (clase 2). Se arregla con `lubridate::yq()` +
  `scale_x_date()` en cada script de viz. Es media hora de trabajo para los diez indicadores.
- **Los títulos nombran variables en vez de afirmar hallazgos** (esta clase). Hay que reescribir los
  diez `labs()`.
- **La auditoría de la paleta** (clase 2) quedó con una recomendación: portar el grosor redundante
  del tema viejo. Falta decidir e implementar.
- **El markdown que ejecuta los scripts y arma el informe** todavía no existe (lo pide `CLAUDE.md`).

### Las tres ideas del taller

1. **Un gráfico es un mapeo de datos a propiedades visuales**, y los canales no son
   intercambiables. (Clase 1)
2. **La pregunta define la herramienta**, y un gráfico claro igual puede mentir. (Clase 2)
3. **El circuito es reproducible de punta a punta.** Que un indicador se actualice solo cuando sale
   una onda nueva no es magia: es que las tres etapas están separadas y el CSV es el contrato entre
   los dos equipos. (Clase 3)
