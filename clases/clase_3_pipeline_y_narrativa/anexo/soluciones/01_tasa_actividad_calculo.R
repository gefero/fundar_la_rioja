# =============================================================================
# CLASE 3 - PASO 1: SOLUCIÓN
# Destino final: src/06_prep_tasa_actividad.R
# =============================================================================

library(tidyverse)

desoc  <- read_csv("data/inputs_md/04_tasa_desoc.csv",  show_col_types = FALSE)
empleo <- read_csv("data/inputs_md/10_tasa_empleo.csv", show_col_types = FALSE)

# Cada fila de los dos CSV está identificada de forma única por el par
# (fecha, la_rioja_region): un valor por trimestre y por región. Ese par es la
# clave del join.
tasa_actividad <- desoc %>%
  select(fecha, la_rioja_region, desoc, pea) %>%
  left_join(
    empleo %>% select(fecha, la_rioja_region, ocupado, pob_tot),
    by = c("fecha", "la_rioja_region")
  ) %>%
  mutate(tasa_actividad = pea / pob_tot * 100)


# ---- Verificación -----------------------------------------------------------

nrow(tasa_actividad)                                        # 216 = 72 × 3
tasa_actividad %>% filter(if_any(everything(), is.na))      # 0 filas

tasa_actividad %>%
  mutate(control = ocupado / pob_tot * 100 + desoc / pob_tot * 100,
         dif     = abs(tasa_actividad - control)) %>%
  summarise(dif_maxima = max(dif))                          # ~1e-14


# ---- Escribir el CSV --------------------------------------------------------

tasa_actividad %>%
  select(fecha, la_rioja_region, pea, pob_tot, tasa_actividad) %>%
  arrange(fecha, la_rioja_region) %>%
  write_csv("data/inputs_md/06_tasa_actividad.csv")


# =============================================================================
# RESPUESTAS
# =============================================================================
#
# 1. ¿Por qué la tasa de actividad NO es tasa_empleo + tasa_desoc?
#    Porque tienen DENOMINADORES DISTINTOS. Mirando
#    src/02_indicadores_eph_individuo.R:
#
#      tasa_empleo    = ocupados    / POBLACIÓN TOTAL × 100
#      tasa_desoc     = desocupados / PEA             × 100      ← ¡PEA!
#      tasa_actividad = PEA         / POBLACIÓN TOTAL × 100
#
#    La tasa de desocupación se calcula sobre la PEA (es "% de la PEA", como
#    dice el README), no sobre la población. Por eso hay que reconstruir el
#    numerador correcto: desocupados / pob_tot, que es lo que hace el control.
#
#    Es un error muy común y da diferencias grandes: en 2025-Q4 La Rioja tiene
#    ~48,9% de actividad y ~43% de empleo, pero la tasa de desocupación es ~6%
#    de la PEA (no de la población). 43 + 6 = 49 da parecido por casualidad;
#    con tasas de desocupación altas la cuenta se rompe del todo.
#
# 2. ¿Y con inner_join()?
#    Con estos datos, exactamente lo mismo: los dos CSV salen del mismo dataset
#    canónico y del mismo group_by, así que tienen las mismas 216 combinaciones.
#    La diferencia aparece si un CSV tuviera trimestres que el otro no:
#      - left_join  conserva todas las filas de `desoc` y pone NA en las
#        columnas de `empleo` que falten → el problema queda VISIBLE como NA.
#      - inner_join descarta esas filas → el problema queda INVISIBLE, la serie
#        simplemente tiene menos puntos y nadie se entera.
#    Por eso el left_join + el chequeo de NA es la combinación defensiva: no
#    evita el problema, pero lo hace ruidoso.
#
# 3. ¿Qué riesgo tiene derivar un indicador de OTROS indicadores?
#    Este es el punto importante del ejercicio.
#
#    Los dos CSV de origen se generan en el mismo script y hoy comparten filtro
#    (`filter(ANO4 >= 2007)`). Pero nada lo garantiza hacia adelante: si alguien
#    cambia el filtro de años de uno solo (como ya pasa con el indicador 03b,
#    que tiene su propio `ANO_DESDE_SALARIOS <- 2009`) el join empieza a
#    devolver NA o a perder filas, y este script no lo sabe.
#
#    Es una dependencia frágil, y por eso este camino sirve para el taller pero
#    NO es donde debería vivir el indicador en producción. Lo correcto es
#    calcularlo desde el dataset canónico, junto a los demás, en
#    src/02_indicadores_eph_individuo.R (ver la variante avanzada, abajo).
#
#    La regla general: un indicador debería depender de LOS MICRODATOS, no de
#    otro indicador. Cada nivel de derivación agrega un supuesto que nadie
#    documenta.


# =============================================================================
# VARIANTE AVANZADA - desde el dataset canónico
# =============================================================================
# Requiere haber corrido 00 y 01 (los microdatos NO están versionados).
# Este bloque va en src/02_indicadores_eph_individuo.R, junto a los demás.
#
# df <- read_rds("./data/proc_data/eph_individuo.rds")
#
# #### 06. Tasa de actividad
# df %>%
#   filter(ANO4 >= 2007) %>%
#   group_by(fecha, la_rioja_region) %>%
#   summarise(pea     = sum(pea * PONDERA),
#             pob_tot = sum(PONDERA),
#             .groups = "drop") %>%
#   mutate(tasa_actividad = pea / pob_tot * 100) %>%
#   write_csv('./data/inputs_md/06_tasa_actividad.csv')
#
# Son seis líneas, calcadas del bloque de tasa de empleo. Y el resultado tiene
# que ser IDÉNTICO al del join: `pea` sale del mismo sum(pea * PONDERA) y
# `pob_tot` del mismo sum(PONDERA).
#
# Si no diera igual, la causa está en los filtros: el bloque de tasa de empleo
# y el de tasa de desocupación tienen que estar filtrando los mismos años.
# Encontrar esa diferencia es el mejor ejercicio del taller.
