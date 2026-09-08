# Práctica - Clase 3

**Duración:** ~18 minutos en clase (el resto del material queda para hacer en casa). **En parejas de
perfiles mezclados.**

Dos partes cortas. La Parte 1 la lleva adelante el perfil mantenimiento; la Parte 2 se hace entre
los dos.

---

## Parte 1 · Terminar el bump chart *(perfil mantenimiento, ~9')*

**Archivo:** `ejercicios/02_bump_pbg.R` — tiene el esqueleto con cuatro `______`.

Es la versión simplificada del ranking de PBG per cápita provincial (`src/15_pbg_ranking_percapita.R`).
Trabajás sobre `data/inputs_md/15_pbg_per_capita_por_provincia.csv`, que **ya está versionado**
(24 provincias × 15 años).

Completá:

| TODO | Qué |
|---|---|
| 1 | El ranking: `min_rank(desc(pbg_per_capita))` dentro del `group_by(anio)`. **El gráfico dibuja el ranking, no el valor.** |
| 2 | `scale_y_reverse(breaks = 1:24)` — el puesto 1 va arriba. |
| 3 | `scale_linewidth_manual(values = c(0.3, 0.5, 1.4))` — contexto fino, La Rioja gruesa. |
| 4 | El `filter()` de la etiqueta: quedarte con la fila de La Rioja en el último año. |

**El resultado** tiene que dejar ver de un vistazo en qué puesto está La Rioja y si subió, bajó o
se mantuvo entre 2010 y 2024.

**Preguntas:**

1. ¿Por qué `group = provincia` y no `group = la_rioja_region`?
2. Si sacás `scale_y_reverse()`, ¿qué le pasa a la lectura de "mejorar en el ranking"?
3. El PBG provincial es una estimación. Si La Rioja pasa del puesto 20 al 19 entre dos años,
   ¿es una tendencia? ¿Qué pondrías en el caption?

> **La idea de fondo:** un bump chart **es** un gráfico de líneas. `data → aes → geom → scale →
> theme → labs`, igual que `src/12_educ.R`. Lo único que cambia son esas tres cosas: la
> transformación a ranking en el paso de datos, el eje Y invertido, y el patrón figura/fondo.

Solución completa: `soluciones/02_bump_pbg.R`.

---

## Parte 2 · Simulacro de actualización + recorrido inverso *(los dos, ~7')*

### a) Simulacro *(4')*

Sin descargar un solo microdato, vas a ver el último eslabón funcionando solo.

1. Abrí `data/inputs_md/04_tasa_desoc.csv` y mirá el último trimestre.
2. Agregá al final tres filas ficticias para `2026-Q2` (una por región). Columnas:
   `fecha,la_rioja_region,desoc,pea,tasa_desoc`.
3. Corré `source("src/04_desoc.R")` desde la raíz del repo.
4. Abrí `outputs/plots/04_desoc.png`: la serie llega un trimestre más lejos.
5. **Revertí con git:** `git checkout data/inputs_md/04_tasa_desoc.csv`

**Pregunta:** en un flujo real, ¿quién escribe esa fila en vez de vos? ¿Después de qué dos etapas?

### b) Recorrido inverso *(3')*

Para **uno** de estos tres números (el que más les interese), encontrá la cadena completa: el CSV,
la columna, el script que lo calcula y la fuente cruda.

| # | Número publicado | Gráfico |
|---|---|---|
| 1 | Tasa de desocupación de La Rioja, último trimestre | `outputs/plots/04_desoc.png` |
| 2 | % de hogares de La Rioja con alguna NBI | `outputs/plots/13a_nbi_hogares.png` |
| 3 | Salario promedio del sector privado registrado en La Rioja | `outputs/plots/03_salarios_privados_SIPA.png` |

Pista: empezá por el script de viz (`src/NN_*.R`), fijate qué CSV lee, y de ahí subí por el
diagrama del `guion.md`. El nº 3 **no pasa por la EPH**.

Solución: `soluciones/03_simulacro_actualizacion.md`.

---

## Para la puesta en común

- El título que le pusieron al bump (Parte 1, TODO del `labs()`). Los comparamos entre parejas.
- Del recorrido inverso: ¿en qué eslabón se les hizo menos obvio de dónde salía el número?
- Una cosa del circuito que les haya resultado más frágil de lo que esperaban.

---

## Material para seguir en casa (opcional)

### El gráfico de líneas paso a paso

`ejercicios/01_lineas_educacion.R` reconstruye `src/12_educ.R` sobre `12_mayor_25_superior.csv`,
parando en las cuatro decisiones que lo vuelven un gráfico del monitor (eje X con fechas reales,
`factor()` para el orden de dibujo, eje Y en cero, la paleta del proyecto). Solución en
`soluciones/01_lineas_educacion.R`.

### Agregar un indicador nuevo de punta a punta

El recorrido completo del circuito —calcular un indicador que hoy no existe, graficarlo, registrarlo
en el dashboard y abrir el PR— está en el `practica.Rmd`, sección "Variante avanzada". El indicador
es la **tasa de actividad** (PEA sobre población total), derivable de dos CSV ya versionados.
