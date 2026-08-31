# Anexo - Recorrido integrador: agregar un indicador nuevo al monitor

Este es el ejercicio que antes era la práctica completa de la Clase 3. Se archiva acá como
**recorrido opcional**, para quien termine antes los dos bloques de la clase o quiera llevarse el
circuito completo a su propio ritmo, fuera del taller.

## Qué es

Recorre de punta a punta los seis pasos de agregar un indicador que hoy no existe en el proyecto -
la **tasa de actividad** (población económicamente activa sobre población total) - desde el
cálculo hasta el Pull Request:

1. **El cálculo** (`ejercicios/01_tasa_actividad_calculo.R`): `left_join()` de
   `data/inputs_md/04_tasa_desoc.csv` y `data/inputs_md/10_tasa_empleo.csv`, más las tres
   verificaciones (filas, `NA`, identidad conceptual `actividad ≈ empleo + desocupados/pob_tot`).
2. **Verificar**: incluido en el mismo script.
3. **La narrativa**: título, subtítulo y caption para el indicador nuevo.
4. **El gráfico** (`ejercicios/02_tasa_actividad_viz.R`): siguiendo el patrón de `src/04_desoc.R`.
5. **El dashboard** (`soluciones/03_registro_dashboard.md`): la entrada en `INDICADORES` de
   `dashboard/R/data.R` y cómo verificar que aparece en `shiny::runApp("dashboard")`.
6. **Publicar**: rama, commit, push y Pull Request.

## Cómo usarlo

Los dos scripts de `ejercicios/` tienen los mismos `______` que la práctica anterior de la clase;
las soluciones completas están en `soluciones/`, incluida la explicación de por qué
`tasa_actividad`, `tasa_empleo` y `tasa_desoc` no comparten denominador (la pregunta que más costó
en las primeras corridas del taller).

Es un buen ejercicio para quien quiera practicar el circuito completo con más tiempo del que da la
clase, o como referencia para agregar un indicador real más adelante - el patrón (`06_prep_`, join,
verificación, gráfico, registro, PR) es el que sigue el repositorio.

**Insumos:** solo los CSV ya versionados de `data/inputs_md/`; no hace falta descargar microdatos.
