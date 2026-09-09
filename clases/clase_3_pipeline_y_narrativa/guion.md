# Clase 3 - Del CSV al monitor: construir los gráficos y mantener el pipeline

**Duración:** 120 minutos · **Teoría y demo:** ~91' · **Práctica:** 18' · **Pausa + cierre:** 11'

**Material de slides:** todas nuevas (~10). **Material de apoyo, impreso:**
[`cheatsheet_repo.md`](../materiales/cheatsheet_repo.md) y
[`checklist_visualizacion.md`](../materiales/checklist_visualizacion.md).

**Objetivo de la clase:** cerrar el circuito. Las clases 1 y 2 fueron sobre el gráfico como objeto;
esta es sobre **el flujo que lo produce**: qué archivo lo dibuja, de dónde salió el CSV que lee, qué
cadena de scripts hay detrás, y qué tiene que hacer alguien de la provincia cuando sale un dato
nuevo. Al final, cada perfil tiene que poder: construir un gráfico del monitor desde su CSV
(mantenimiento) y saber qué advertencia va en el caption (comunicación).

Es la clase donde los dos perfiles hacen cosas distintas pero acopladas. Conviene decirlo al
arrancar: **la práctica final los obliga a trabajar juntos**, así que nadie se desengancha en la
mitad que no le toca.

---

## 0–8' · El último eslabón: anatomía de un script de visualización

**Foco:** los dos. **Slides nuevas: 1.**

Abrir [`src/12_educ.R`](../../src/12_educ.R) proyectado. Son 29 líneas y hacen **todo** lo que hace
un indicador del monitor de punta a punta en la parte visual:

```r
library(tidyverse)
source('./style/fundar_monitor_theme.R')                    # 1. el tema del proyecto

df <- read_csv('./data/inputs_md/12_mayor_25_superior.csv')  # 2. LEE un CSV de inputs_md/

df_plot <- df %>% mutate(la_rioja_region = factor(la_rioja_region))

quiebres_x <- sort(unique(df_plot$fecha))                    # 3. prepara el eje X
quiebres_x <- quiebres_x[grepl("Q1$|Q3$", quiebres_x)]

df_plot %>%
  ggplot(aes(x = fecha, y = porc_mayor_25_superior,          # 4. el gráfico (gramática clase 1)
             group = la_rioja_region, color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  ylim(0, 35) +
  scale_color_fundar_multi(name = "Región") +
  scale_x_discrete(breaks = quiebres_x) +
  theme_monitor() +
  labs(title = "...", x = "...", y = "...", caption = fuente_fundar("EPH-INDEC"))

ggsave('./outputs/plots/12_educ.png', width = 12, height = 8)  # 5. ESCRIBE un PNG
```

**La cadena completa, en una slide:**

```
data/inputs_md/12_mayor_25_superior.csv   ←  el CSV versionado (la "frontera")
        │   src/12_educ.R  (lee el CSV, dibuja, guarda el PNG)
        ▼
outputs/plots/12_educ.png
        │
        └──►  informe/monitor_la_rioja.Rmd   (lo inserta con mostrar("outputs/plots/12_educ.png"))
```

**Los dos puntos a fijar:**

1. **Todos los scripts de viz son el mismo archivo.** Abrir [`src/04_desoc.R`](../../src/04_desoc.R)
   y [`src/13a_nbi_hogares.R`](../../src/13a_nbi_hogares.R) al lado: cambia el nombre del CSV, la
   columna `y`, el `ylim` y los textos. Nada más. **Si sabés hacer uno, sabés hacer los diez.**
2. **El script no calcula el indicador.** El número ya viene hecho en el CSV. El script de viz solo
   lo dibuja. De dónde sale ese número es el Bloque B. Por eso el CSV, y no el PNG, es lo que importa
   versionar: si el número está mal, se corrige en el CSV y el PNG se vuelve a generar solo.

### Demo (2')

Correr `source("src/12_educ.R")` en vivo y abrir el PNG recién escrito en `outputs/plots/`. Ese es
el loop completo: editar el script, correrlo, mirar el PNG.

---

## 8–22' · Gráfico de líneas: lo que ya saben, y lo que lo vuelve del monitor

**Foco:** mantenimiento (comunicación mira). **Slides nuevas: 1.**

La gramática de un gráfico de líneas ya se vio entera en la clase 1 (reconstrucción de `04_desoc.R`
capa por capa). Acá se recorre rápido sobre un CSV nuevo —`12_mayor_25_superior.csv`— y se para en
**las cuatro decisiones que separan un gráfico de exploración de uno del monitor**:

| Decisión | En el código | Por qué |
|---|---|---|
| `factor(la_rioja_region)` | `mutate(la_rioja_region = factor(...))` | Fuerza el orden `1 < 2 < 3`: La Rioja se dibuja **última**, queda por encima cuando las líneas se cruzan (idea recurrente del taller). |
| Eje Y en cero | `ylim(0, 35)` | Una serie de porcentajes se lee sobre el cero. Sin esto, `ggplot` recorta y exagera la variación (integridad visual, clase 2). |
| La paleta del proyecto | `scale_color_fundar_multi()` | Sin esta línea `ggplot` elige tres colores de igual peso y La Rioja no salta. |
| El eje X domado | `scale_x_discrete(breaks = quiebres_x)` | `fecha` es texto (`"2007-Q1"`), 75 categorías. El truco `grepl("Q1$|Q3$")` deja 2 marcas por año. |

**El punto sobre el eje X, que es el más importante para mantenimiento.** Hay dos formas de
domarlo en el repo, y conviven:

- **`scale_x_discrete(breaks = quiebres_x)`** — deja `fecha` como texto y solo muestra algunas
  etiquetas. Es lo que hacen hoy `04_desoc.R`, `12_educ.R`, `13a_nbi_hogares.R`.
- **`lubridate::yq(fecha)` + `scale_x_date()`** — convierte a fecha real y deja que `ggplot` elija
  marcas cada N años. Es lo que recomienda la clase 2 y lo que se pide en la práctica.

Los dos resuelven el mismo problema (72 etiquetas ilegibles). El segundo es más robusto: si mañana
hay datos mensuales, sigue funcionando. **En la práctica se usa el segundo.**

### Demo (3')

Partir del gráfico "crudo" (sin las cuatro decisiones) y agregarlas de a una, ejecutando en cada
paso. Es el mismo ejercicio de la clase 1 pero acelerado, para que quede fresco antes del bump.

---

## 22–42' · Bump chart desde cero

**Foco:** mantenimiento. **Slides nuevas: 2.**

El bump chart (o *slopegraph* de ranking) responde una pregunta que la serie de tiempo no responde
bien: **¿en qué puesto está La Rioja respecto de las otras provincias, y cómo cambió ese puesto?**
El repo lo usa en [`src/15_pbg_ranking_percapita.R`](../../src/15_pbg_ranking_percapita.R) para el
PBG per cápita. Vamos a reconstruir una versión más simple.

**Datos:** [`data/inputs_md/15_pbg_per_capita_por_provincia.csv`](../../data/inputs_md/15_pbg_per_capita_por_provincia.csv)
— 360 filas = 24 provincias × 15 años (2010–2024). Columnas que importan: `anio`, `provincia`,
`pbg_per_capita`, `la_rioja_region`.

### La idea clave: es la MISMA gramática que las líneas

`data → aes → geom → scale → theme → labs`. Un bump chart **es** un gráfico de líneas. Lo que
cambia son tres cosas, y conviene nombrarlas en una slide:

**1. Una transformación en el paso de datos: de valor a ranking.**

```r
rank_df <- prov %>%
  group_by(anio) %>%
  mutate(ranking = min_rank(desc(pbg_per_capita))) %>%   # 1 = el PBG pc más alto de ese año
  ungroup()
```

El gráfico **no dibuja `pbg_per_capita`**, dibuja `ranking`. Este es el concepto que hay que dejar
clavado: *muchas veces el gráfico no grafica la columna que viene en el CSV, sino algo derivado de
ella en el propio script de viz*. Acá es un ranking; en otros casos es un índice base 100, una media
móvil, una variación interanual.

> **Por qué el ranking sí se puede comparar entre años aunque el nivel no.** El PBG per cápita de
> `15_pbg_per_capita_por_provincia.csv` está en pesos constantes de 2004, así que el nivel es
> comparable — pero incluso si estuviera en pesos corrientes (como el salario del indicador 03), el
> **ranking dentro de un mismo año** sería inmune a la inflación, porque afecta a las 24
> jurisdicciones por igual. Es el mismo argumento que el material extra de la clase 2
> (`soluciones/05_bump_salarios.R`).

**2. `scale_y_reverse()`: el puesto 1 va arriba.**

Un ranking se lee con el mejor arriba. Sin `scale_y_reverse()`, el puesto 1 queda abajo y el
gráfico se lee al revés de como lo espera el ojo.

**3. El patrón figura/fondo.**

24 líneas del mismo color son ilegibles. La solución es la misma paleta regional del monitor: las
provincias de contexto ("1. Resto país") en un tono claro que no se puede —ni se necesita— seguir
individualmente; el NOA-Resto en el tono medio; **La Rioja en el teal oscuro, la única que se sigue
punto por punto**. Y como el CSV ya trae `la_rioja_region`, el mapeo sale directo:

```r
ggplot(rank_df, aes(anio, ranking, group = provincia, color = la_rioja_region)) +
  geom_line(aes(linewidth = la_rioja_region)) +
  scale_color_fundar_multi() +
  scale_linewidth_manual(values = c(0.3, 0.6, 1.4)) +   # contexto fino, La Rioja gruesa
  scale_y_reverse(breaks = 1:24) +
  ...
```

Reemplaza a la leyenda una **etiqueta al final de la línea de La Rioja** (`geom_text` sobre
`filter(anio == max(anio))`, con `coord_cartesian(clip = "off")` y margen a la derecha).

### Demo en vivo (10')

Construir el bump capa por capa, ejecutando en cada paso, **hasta el esqueleto con los huecos**. No
terminarlo: los huecos (`min_rank`, `scale_y_reverse`, el `scale_linewidth_manual`, la etiqueta) son
exactamente lo que completan en la práctica. Dejar el archivo abierto.

**Preguntas para tirar a la sala mientras se construye:**

- ¿Por qué `group = provincia` y no `group = la_rioja_region`? (Porque hay 24 líneas, una por
  provincia; el color agrupa de a tres pero la línea es por provincia.)
- ¿Qué pasa si saco `scale_y_reverse()`? (El gráfico se da vuelta y "subir en el ranking" se ve
  como bajar.)
- Con `color = la_rioja_region` no puedo distinguir las 18 provincias del "Resto país" entre sí.
  ¿Es un problema? (No: son contexto. La pregunta es sobre La Rioja.)

---

## 42–56' · Narrativa: el gráfico es soporte de un texto

**Foco:** comunicación (mantenimiento mira). **Slides nuevas: 3.** Fuente:
[`Informe_final_argendata.pdf`](../materiales/Informe_final_argendata.pdf), págs. 40–42.

### La regla de fondo

> El gráfico es **soporte de una narrativa**. Si el texto habla de cuatro cosas, no muestres doce.
> **La granularidad del gráfico tiene que igualar la del texto.**

El informe lo muestra con el caso ENGHo: el análisis publicado menciona cuatro rubros de consumo, el
gráfico desagrega doce. La solución no es un gráfico más lindo: es **desagregar solo lo que el texto
discute** y agregar el resto. En el monitor pasa lo mismo con las cinco sub-dimensiones de NBI: hoy
`13a_nbi_hogares.R` grafica solo el total, y está bien, porque el análisis habla del total.

### Los tres campos de texto de un gráfico

Concreto y aplicable ya. Ir al `labs()` de [`src/04_desoc.R`](../../src/04_desoc.R):

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
| **Subtítulo** | Unidad, universo, período y cualquier transformación aplicada | "Desocupados como % de la PEA. Aglomerado La Rioja, 2007–2025, promedio de las 4 ondas de cada año." |
| **Caption** | Fuente completa **y las advertencias metodológicas** | "Fuente: Fundar, con base en la EPH (INDEC). Serie interrumpida entre 2015-T3 y 2016-T1." |

Ejercicio con la sala (5'): proyectar tres PNG de `outputs/plots/` y **reescribir los títulos entre
todos**. Rápido y deja el punto clavado.

### El mejor y el peor ejemplo, los dos del repo

- **El mejor:** [`src/03b_salarios_registrados_EPH.R`](../../src/03b_salarios_registrados_EPH.R). Su
  caption dice explícitamente que la línea punteada marca el cambio de metodología de ingresos de la
  EPH (2015-2016) y que los niveles a ambos lados no son comparables, **y el gráfico dibuja esa
  línea**. El lector tiene lo que necesita para no sacar una conclusión falsa.
- **El peor:** el título de `04_desoc.R` es el nombre de la variable y no dice nada. Los diez
  indicadores tienen el mismo problema — es deuda pendiente del repo.

### La advertencia muestral, que es específica de este proyecto

Ya apareció en la clase 2, pero se repite porque es la que más se olvida:

> **La Rioja es un dominio chico de la EPH.** Nunca reportar un nivel a partir de un solo trimestre:
> promediar las cuatro ondas del año. Y un `0,00` en una sub-dimensión de NBI **no significa "no hay
> privación"**, significa "la muestra no alcanza para medirlo". Si se publica, hay que decirlo en el
> caption.

Para el bump del Bloque A esto también aplica: el PBG provincial es una estimación, así que un
cambio de **un solo puesto** entre dos años consecutivos probablemente sea ruido, no una tendencia.

---

## 56–60' · Pausa

---

## 60–85' · La lógica del monitor: de dónde sale cada número

**Foco:** los dos. **Slides nuevas: 3.**

### El diagrama (la slide más importante de la clase)

```
   INDEC (EPH)                         SIPA · OPEX · CEPAL · Min. Economía · SRT
        │                                            │
        ▼                                            ▼
┌─────────────────────┐                   ┌────────────────────────┐
│ 00_descarga_eph.R   │  ETAPA 1          │ NN_prep_<fuente>.R     │  (lee el xlsx/xls crudo,
└─────────────────────┘  descarga            └────────────────────────┘   homologa nombres, recorta)
        │  → data/raw_data/eph/**/*.rds        │  → data/inputs_md/*.csv
        │     [NO versionado]                  │
        ▼                                      │
┌─────────────────────┐                        │
│ 01_limpieza_eph.R   │  ETAPA 2               │
└─────────────────────┘  limpieza y            │
        │  canonización                        │
        │  → data/proc_data/eph_*.rds          │
        │     [NO versionado]                  │
        ▼                                      │
┌─────────────────────┐                        │
│ 02_indicadores_*.R  │  ETAPA 3               │
└─────────────────────┘  cálculo               │
        │  → data/inputs_md/*.csv              │
        │     [★ VERSIONADO ★] ◄───────────────┘
        │
        ├──────────────────────┐
        ▼                      ▼
   src/NN_*.R             informe/monitor_la_rioja.Rmd
   → outputs/plots/       (inserta los PNG)
```

**Las tres cosas que hay que explicar de este diagrama:**

1. **Por qué la EPH tiene tres etapas y no un script.** Para poder re-ejecutar solo una parte.
   Recalcular un indicador no requiere volver a descargar ni relimpiar 19 años de microdatos. La
   descarga completa tarda varios minutos; el cálculo de indicadores, segundos. Las fuentes no-EPH
   son más chicas y colapsan a un solo `prep`.
2. **Por qué `data/raw_data/` está en `.gitignore` y `data/inputs_md/` no.** Los microdatos pesan
   ~1 GB, se regeneran solos y no tiene sentido versionarlos. Los CSV agregados pesan poco, **se
   revisan en un diff** (si un indicador cambia, se ve exactamente en qué), y son lo que consume
   cada script de viz.
3. **La línea con la estrella es la frontera del taller.** Es la misma que se presentó en la clase 1.
   Todo lo de arriba es del equipo de datos; todo lo de abajo, del de comunicación. El contrato es
   el CSV: si tiene las columnas esperadas y los datos correctos, las dos mitades trabajan en
   paralelo sin pisarse.

### Recorrido inverso: de un punto del gráfico a la línea de código (7')

Es la mejor forma de que el diagrama deje de ser abstracto. Tomar **el gráfico de líneas del
Bloque A** (`12_educ.png`) y rastrear un punto hacia atrás, en vivo:

| Pregunta | Respuesta | Archivo |
|---|---|---|
| ¿Qué dibuja este punto? | `porc_mayor_25_superior` para La Rioja en 2024-Q3 | `src/12_educ.R` |
| ¿De dónde salió ese número? | Una fila de `12_mayor_25_superior.csv` | `data/inputs_md/12_mayor_25_superior.csv` |
| ¿Quién escribió esa fila? | El bloque "12." de `02_indicadores_eph_individuo.R`: `sum(mayor_25_superior * PONDERA) / sum(PONDERA) * 100` | `src/02_indicadores_eph_individuo.R` |
| ¿De dónde sale `mayor_25_superior`? | Se deriva en la limpieza: `mayor_25 == 1 & niv_educ_sup == 1`, a partir de `CH06` y `NIVEL_ED` | `src/01_limpieza_eph.R` |
| ¿Y `CH06` / `NIVEL_ED`? | Columnas crudas de la EPH, descargadas por | `src/00_descarga_eph.R` → `data/raw_data/eph/individuo/2024_3_EPH_individuo.rds` |

Repetir el ejercicio, más corto, con el **bump**: el punto → `15_pbg_per_capita_por_provincia.csv`
→ `15_prep_pbg_per_capita.R` (VAB × 1e6 / población) → el xlsx de CEPAL en `data/raw_data/pbg/` y
la población de DNAP. **La EPH no aparece en esta cadena** — es una fuente distinta, con su propio
`prep`.

### Las cuatro trampas (una slide, para dejar pegada al monitor)

Todas documentadas en el README y en los comentarios del código, y las cuatro ya se pisaron:

1. **La descarga incremental no re-descarga.** Si agregás una variable a `vars_individuo`, los
   `.rds` que ya existen **no** se actualizan: el paso saltea archivos existentes. Hay que
   **borrarlos** y volver a correr `00`. Es la causa nº 1 de "agregué la variable y me viene todo
   `NA`".
2. **El orden de `as.character()` en `limpiar_base_eph()`.** Primero se castean a texto las columnas
   categóricas (sobre un objeto `labelled`, `as.character()` devuelve la **etiqueta**: `"Casa"`), y
   **recién después** se pela la clase `labelled` del resto. Al revés, devuelve el **código**
   (`"2"`), y todas las comparaciones de texto (`case_when`, `%in%`, `==`) dejan de matchear **en
   silencio, sin error ni warning**. Es el bug más difícil de detectar del pipeline: no rompe nada,
   solo te da todo mal.
3. **El quiebre 2015/2016.** `PONDIIO` no existe antes de ~2016 (la EPH imputaba los ingresos y no
   publicaba el ponderador de ingreso), así que el cálculo de salarios usa `PONDERA` como fallback.
   Consecuencia: **los niveles a ambos lados no son comparables**, y encima la EPH estuvo
   interrumpida entre 2015-T3 y 2016-T1. Todo gráfico de salarios tiene que marcar el quiebre.
4. **La Rioja es un dominio chico.** En un trimestre suelto varias sub-dimensiones de NBI dan
   `0,00`. No es que no haya privación: la muestra no alcanza. Promediar las cuatro ondas del año
   antes de comunicar un nivel.

Las trampas 3 y 4 no son detalles técnicos para el perfil comunicación: son exactamente lo que
tiene que aparecer en el caption de un gráfico publicado.

---

## 85–95' · Cómo se actualiza y cómo se publica

**Foco:** los dos. **Slides nuevas: 2.** Apoyo: [`cheatsheet_repo.md`](../materiales/cheatsheet_repo.md).

### El playbook

| Salió dato nuevo de… | Pasos | Frecuencia |
|---|---|---|
| **EPH continua** (04, 09a, 10, 12, 13a, 13b, 03b) | `source("src/00_descarga_eph.R")` → `01` → `02_*` → los scripts de viz afectados | Trimestral |
| **SIPA** (03, 05) | Reemplazar el `.xlsx` en `data/raw_data/sipa/` → `NN_prep_*` → viz | Mensual |
| **CEPAL / PBG** (15) | Reemplazar el Excel en `data/raw_data/pbg/` → `15_prep_pbg.R` → `15_prep_pbg_per_capita.R` → viz | Cuando publiquen |
| **OPEX, SRT, finanzas, educación** | Ídem: reemplazar raw → `prep` → viz | Anual |

`descargar_eph_incremental()` llega sola hasta el año en curso: **no hay que editar el rango a
mano** cuando sale una onda nueva. Si un trimestre todavía no está publicado, avisa por consola y
sigue.

La opción de fuerza bruta, cuando no se sabe qué se tocó: `source("src/999_run_pipeline.R")` corre
todo de punta a punta.

### El circuito de publicación

```bash
git checkout -b actualizo-eph-2026q2     # NUNCA trabajar directo sobre main
git add data/inputs_md/ outputs/plots/
git commit -m "Actualizo indicadores EPH con la onda 2026-T2"
git push -u origin actualizo-eph-2026q2
# → abrir un Pull Request en GitHub
```

Por qué una rama y un PR: **el push a `main` publica**. El workflow
[`.github/workflows/dashboard.yml`](../../.github/workflows/dashboard.yml) se dispara al mergear a
`main` un cambio en `data/inputs_md/`, `style/` o el propio workflow, y republica el sitio de
`clases/` en `gh-pages`. **Actualizar un CSV dispara esa republicación sola.** La rama permite que
otro mire el cambio antes de que salga.

> **Prioridad si falta tiempo.** Si el Bloque B se pasa de las 85', recortar el recorrido inverso
> del bump (dejar solo el de educación) y **no** la tabla de actualización: es lo que se llevan
> como referencia de trabajo.

---

## 95–113' · Práctica integradora

Consigna completa en [`practica.md`](practica.md). **En parejas de perfiles mezclados.** Reformulada
para pesar hacia la **lectura e interpretación**, no hacia completar código: los `______` de
siempre quedaron como refuerzo opcional para la casa, al final de `practica.md`.

### Parte 1 · Lectura de gráficos *(los dos, ~8')*

**1a. Antes/después** (4'): mostrar [`plots/clase3_educ_crudo.png`](plots/clase3_educ_crudo.png) —
el mismo dato de `12_mayor_25_superior.csv` dibujado sin ninguna de las cuatro decisiones de la
clase 1 (eje X ilegible, eje Y sin cero, sin paleta, título = nombre de variable). Sin mostrar el
código: que nombren qué está mal. Recién después comparar con `outputs/plots/12_educ.png` y mapear
cada problema a la decisión que lo resuelve.

**1b. Errores plantados** (4'): mostrar
[`plots/clase3_desoc_con_errores.png`](plots/clase3_desoc_con_errores.png) — la tasa de
desocupación con **dos errores de integridad visual metidos a propósito**: el eje Y recortado
(3–12, cuando el real va de 0 a ~21 y además corta el pico de 2020) y las tres regiones en el mismo
color pálido con La Rioja dibujada primero (tapada donde las líneas se cruzan). Encontrarlos sin ver
el original, después comparar con `outputs/plots/04_desoc.png`.

### Parte 2 · Predicción: leer código sin correrlo *(los dos, ~6')*

Cuatro tarjetas en `practica.md`, variaciones del bump chart de PBG per cápita (código de
`ejercicios/02_bump_pbg.R`, mostrado como texto — no hace falta correr nada). Para cada una,
predicen qué cambia en el gráfico antes de leer la respuesta: sacar la transformación a ranking,
sacar `scale_y_reverse()`, agrupar por región en vez de por provincia, y el efecto (parcial) del
grosor de línea sin `scale_linewidth_manual()`. La tarjeta del `group` es la más rendidora: fuerza a
distinguir "cuántas líneas hay" de "de qué color son".

### Parte 3 · *(pendiente — ver nota abajo)*

> **Nota:** la Parte 3 anterior (simulacro de actualización: fila ficticia + `git checkout`) se
> sacó de la práctica. Reemplazo pendiente, tiene que ser conceptual sobre el pipeline y no
> requerir correr R en vivo.

### Cómo conducirla

Las Partes 1 y 2 enganchan a los dos perfiles por igual — no hay una mitad "de mantenimiento" y otra
"de comunicación", que era el problema de la versión anterior (el bump fill-in-blank se lo llevaba
puesto el perfil de mantenimiento). Si una pareja termina rápido, el rastreo completo del pipeline
(`ejercicios/02_rastreo_pipeline.R`, reactivado como material para la casa) es la extensión natural
de la Parte 1b: agarrar el CSV de la desocupación y seguirle el rastro hasta el `.rds` crudo de la EPH.

> **Nota:** `data/inputs_md/15_pbg_per_capita_por_provincia.csv` (el CSV que usaría el bump chart
> completo, `ejercicios/02_bump_pbg.R`, si se corriera de verdad) todavía no está en el repo — la
> Parte 2 de acá arriba lo esquiva a propósito, usando el código como texto para predecir en vez de
> pedir que se ejecute.

---

## 113–120' · Cierre

### El mapa de pendientes del repositorio

Cerrar con trabajo real. Conviene salir con nombres asignados:

- **Títulos que nombran variables en vez de afirmar hallazgos** (esta clase): reescribir los diez
  `labs()`.
- **El eje X con `scale_x_date()` en todos los scripts de viz** (clase 2): media hora de trabajo,
  diez archivos.
- **El indicador 03 está en pesos corrientes** (clase 2): sumar una serie de IPC para deflactar. Es
  el pendiente de mayor impacto sobre lo publicado. *(Puede que ya esté hecho — chequear
  `03_prep_salarios_privados_SIPA_real.R`.)*
- **El markdown que ejecuta los scripts y arma el informe** ya existe
  (`informe/monitor_la_rioja.Rmd`); faltan integrar los indicadores 17 y 18.

### Las tres ideas del taller

1. **Un gráfico es un mapeo de datos a propiedades visuales**, y los canales no son
   intercambiables. (Clase 1)
2. **La pregunta define la herramienta**, y un gráfico claro igual puede mentir. (Clase 2)
3. **El circuito es reproducible de punta a punta.** Que un indicador se actualice cuando sale una
   onda nueva no es magia: las etapas están separadas, el CSV es el contrato entre los dos equipos,
   y el mismo CSV alimenta el PNG y el informe. (Clase 3)
