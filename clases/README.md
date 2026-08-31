# Taller de visualización de datos - Gobierno de La Rioja

Materiales para las **3 clases de 2 horas** del Componente 3 (Etapa 3: *diseño de materiales para
talleres de visualización de datos*).

> **Publicado:** estos materiales también están en
> **[gefero.github.io/fundar_la_rioja/clases/](https://gefero.github.io/fundar_la_rioja/clases/)**
> - la práctica renderizada, `.Rmd`/`.R` como descarga, un `.zip` por clase (sin `guion.md`: es
> material interno para quien dicta, no se publica). Se regenera solo con cada push a `main` que
> toque `clases/**` (ver [`.github/workflows/dashboard.yml`](../.github/workflows/dashboard.yml)).

## A quién está dirigido

El taller tiene un público mixto y está diseñado alrededor de esa mezcla:

- **Perfil mantenimiento** - quienes van a mantener este repositorio y actualizar los datos
  cuando salga una onda nueva de la EPH o un reporte nuevo del SIPA.
- **Perfil comunicación** - quienes van a tomar estos indicadores y armar los productos de
  difusión: informes, presentaciones, placas, el dashboard.

Los dos perfiles se necesitan, y el taller lo hace explícito con una idea que atraviesa las tres
clases:

> **Los CSV de `data/inputs_md/` son la frontera entre los dos equipos.**
> El equipo de datos garantiza que estén bien calculados y actualizados. El equipo de comunicación
> decide cómo se leen. Ese contrato es lo que permite que las dos mitades trabajen en paralelo.

Por eso la práctica de las clases 2 y 3 se hace **en parejas de perfiles mezclados**: quien comunica
define la pregunta y redacta el título; quien mantiene escribe el código.

## Las tres clases

| # | Clase | Qué se lleva el perfil mantenimiento | Qué se lleva el perfil comunicación |
|---|---|---|---|
| 1 | [Gramática de gráficos y percepción](clase_1_gramatica_y_percepcion/) | Cómo está construido un script de visualización del repo, capa por capa | Por qué un gráfico se entiende o no: marcas, canales y jerarquía perceptual |
| 2 | [Integridad visual y catálogo de herramientas](clase_2_integridad_y_catalogo/) | Cómo implementar herramientas del catálogo (Cleveland, brecha implícita, spaghetti) y cómo auditar una paleta | Cómo elegir el gráfico correcto según la pregunta, y cómo detectar distorsiones |
| 3 | [Un gráfico desde cero y de dónde salen los datos](clase_3_pipeline_y_narrativa/) | Rastrear el pipeline (descarga, limpieza, indicadores) hacia atrás desde un CSV, sin microdatos | Armar un gráfico entero por cuenta propia: pregunta, marca, y los tres campos de texto |

Cada clase tiene la misma estructura:

```
clase_N_.../
├── guion.md       # minutado del dictado: qué se dice, con qué slides y qué anclaje en el repo
├── practica.md    # consignas de los ejercicios, para repartir a los participantes
├── practica.Rmd   # los mismos ejercicios, empaquetados en un notebook único
├── ejercicios/    # los .R de la práctica, sueltos (mismo contenido que practica.Rmd)
└── soluciones/    # scripts .R resueltos
```

`practica.md` y `practica.Rmd` tienen la misma consigna; `ejercicios/*.R` y `practica.Rmd` tienen
el mismo código. Usá lo que prefieras: archivos sueltos para ir de a uno, o el notebook para
navegar toda la clase en un solo documento con la consigna al lado de cada chunk.

> La Clase 3 tiene además una carpeta `anexo/` con el mismo formato (`ejercicios/`, `soluciones/`,
> más un `README.md` propio): es un recorrido integrador opcional, archivado ahí porque no entra en
> el tiempo de la clase.

## Antes de la primera clase

1. **Instalar R (≥ 4.1) y RStudio.**
2. **Clonar el repositorio** y abrir `fundar_larioja.Rproj` en RStudio (esto fija el directorio de
   trabajo, así todas las rutas relativas de los scripts funcionan).
3. **Correr `clases/materiales/00_setup.R`.** Instala los paquetes necesarios, verifica que los
   datos estén en su lugar y dibuja un gráfico de prueba. Si termina con el mensaje
   `✔ Todo listo`, estás en condiciones de hacer la práctica.

> **No hace falta descargar los microdatos de la EPH.** La práctica de las tres clases trabaja sobre
> los CSV ya versionados de `data/inputs_md/`. Los microdatos (`data/raw_data/`, `data/proc_data/`)
> están excluidos del control de versiones y solo aparecen en la demo de la clase 3, sobre uno o dos
> trimestres.

## Materiales de referencia

En [`materiales/`](materiales/):

- **[`catalogo_datos.md`](materiales/catalogo_datos.md)** - una entrada por cada CSV de
  `data/inputs_md/`, con columnas, granularidad, advertencia metodológica y pregunta sugerida. Es
  la base de la elección libre del Bloque A de la Clase 3.
- **[`checklist_visualizacion.md`](materiales/checklist_visualizacion.md)** - una página con el
  checklist completo: qué preguntarse antes de graficar, al graficar y al publicar. Pensado para
  tener al lado mientras se arma un producto de comunicación.
- **[`cheatsheet_repo.md`](materiales/cheatsheet_repo.md)** - una página con el mapa del repositorio
  y los comandos de las tareas frecuentes de mantenimiento.
- **[`Informe_final_argendata.pdf`](materiales/Informe_final_argendata.pdf)** - *Evaluación, análisis
  y propuesta de mejoras del sistema de visualizaciones de Argendata* (Rosati, 2024). Es la fuente
  del catálogo de herramientas gráficas de la clase 2.
- **[`paleta_regional_swatch.R`](materiales/paleta_regional_swatch.R)** - genera un swatch de los
  3 colores regionales, leyendo `FUNDAR_MULTI` desde `style/fundar_monitor_theme.R` (no repite los
  hex), en `outputs/plots/paleta_regional_la_rioja.png`.
- **`../Copia de Pract_Clase_1_introducción.pdf`** - el deck de 169 diapositivas del que salen los
  bloques teóricos de las clases 1 y 2. Los guiones indican qué diapositivas usa cada bloque.

## Bibliografía

- Cleveland, W. S., & McGill, R. (1984). Graphical perception: Theory, experimentation, and
  application to the development of graphical methods. *JASA*, 79, 531–534.
- Healy, K. (2019). *Data Visualization. A practical introduction*. Princeton University Press.
- Munzner, T. (2014). *Visualization Analysis and Design*. CRC Press.
- Quinan, P. et al. (2019). Examining Implicit Discretization in Spectral Schemes.
  *Computer Graphics Forum (EuroVis)*, 38(3), 363–374.
- Tufte, E. (1983). *The Visual Display of Quantitative Information*. Graphics Press.
- Tufte, E. (1997). *Visual Explanations*. Graphics Press.
- Wilkinson, L. (2005). *The Grammar of Graphics*. Springer.
