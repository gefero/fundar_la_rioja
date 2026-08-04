# =============================================================================
# CLASE 3 — PASO 1: el cálculo de un indicador nuevo
# -----------------------------------------------------------------------------
# Copiá este archivo a src/06_prep_tasa_actividad.R y completá los TODO.
#
# La tasa de actividad (PEA sobre población total) no existe hoy en el
# proyecto. Se puede derivar de dos CSV ya versionados, sin descargar un solo
# microdato:
#   04_tasa_desoc.csv  aporta `pea`      (población económicamente activa)
#   10_tasa_empleo.csv aporta `pob_tot`  (población total)
#
#   tasa_actividad = pea / pob_tot * 100
#
# Convención de nombre: el repo ya usa el prefijo `NN_prep_` para los scripts
# que preparan un CSV a partir de otra fuente (ver 03_prep_ y 05_prep_).
# =============================================================================

library(tidyverse)


# ---- Los dos insumos --------------------------------------------------------

desoc <- read_csv("data/inputs_md/04_tasa_desoc.csv",  show_col_types = FALSE)
empleo <- read_csv("data/inputs_md/10_tasa_empleo.csv", show_col_types = FALSE)

glimpse(desoc)    # fecha, la_rioja_region, desoc, pea, tasa_desoc
glimpse(empleo)   # fecha, la_rioja_region, ocupado, pob_tot, tasa_empleo


# ---- El join y el cálculo ---------------------------------------------------
# TODO 1: ¿por qué columnas hay que unir las dos tablas?
#         Pensalo: ¿qué identifica de forma única una fila en cada una?
# TODO 2: completá el cálculo de la tasa.

tasa_actividad <- desoc %>%
  select(fecha, la_rioja_region, desoc, pea) %>%
  left_join(
    empleo %>% select(fecha, la_rioja_region, ocupado, pob_tot),
    by = c(______, ______)                        # <-- TODO 1
  ) %>%
  mutate(tasa_actividad = ______ / ______ * 100)  # <-- TODO 2


# ---- Verificación (NO SALTEAR) ----------------------------------------------
# Antes de graficar nada. Tres chequeos, en este orden.

# 1. ¿Cuántas filas quedaron? Tienen que ser 216 = 72 trimestres × 3 regiones.
nrow(tasa_actividad)

# 2. ¿Hay NA? No tiene que haber ninguno.
tasa_actividad %>% filter(if_any(everything(), is.na))

# 3. La verificación conceptual: la PEA son los ocupados MÁS los desocupados,
#    así que la tasa de actividad tiene que ser igual a la tasa de empleo más
#    los desocupados sobre la población total.
#    Si esta identidad no se cumple, el join está mal.
tasa_actividad %>%
  mutate(
    control = ocupado / pob_tot * 100 + desoc / pob_tot * 100,
    dif     = abs(tasa_actividad - control)
  ) %>%
  summarise(dif_maxima = max(dif))
# → tiene que dar prácticamente 0 (algo como 1e-14, que es error de redondeo
#   de punto flotante, no un problema del cálculo).


# ---- Escribir el CSV --------------------------------------------------------
# Guardamos también las columnas de base (pea, pob_tot), igual que hacen los
# otros indicadores: permiten auditar el cálculo y recalcular sin rehacer todo.

tasa_actividad %>%
  select(fecha, la_rioja_region, pea, pob_tot, tasa_actividad) %>%
  arrange(fecha, la_rioja_region) %>%
  write_csv("data/inputs_md/06_tasa_actividad.csv")


# =============================================================================
# PREGUNTAS
# =============================================================================
# 1. ¿Por qué la tasa de actividad NO es igual a tasa_empleo + tasa_desoc?
#    Las dos son porcentajes... pero ¿de qué? Mirá los denominadores en
#    src/02_indicadores_eph_individuo.R.
#
# 2. Usamos left_join(). ¿Qué habría pasado con un inner_join()? ¿Y si uno de
#    los dos CSV tuviera un trimestre que el otro no tiene?
#
# 3. Este script deriva un indicador de OTROS INDICADORES, no de los microdatos.
#    ¿Qué riesgo tiene eso? (Pista: ¿qué pasa si alguien cambia el filtro de
#    años de uno solo de los dos CSV de origen?)
