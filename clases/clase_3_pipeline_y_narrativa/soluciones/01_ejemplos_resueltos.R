# =============================================================================
# CLASE 3 - BLOQUE A: TRES EJEMPLOS RESUELTOS
# -----------------------------------------------------------------------------
# No son "la" solución - el Bloque A es de elección libre, cada pareja elige
# su propio CSV y su propia pregunta. Estos tres ejemplos muestran el método
# completo (pregunta -> marca -> gráfico -> narrativa) sobre tres CSV y tres
# marcas que las Clases 1 y 2 NO usaron: barras horizontales ordenadas,
# scatter, y small multiples en serie de tiempo (distinto del Cleveland/
# dumbbell transversal de la Clase 2, que usa el mismo CSV de NBI pero para
# comparar DOS momentos, no para ver la trayectoria completa).
#
# Corré este script desde la raíz del repo (vía fundar_larioja.Rproj).
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

dir.create("clases/clase_3_pipeline_y_narrativa/plots", showWarnings = FALSE, recursive = TRUE)


# =============================================================================
# Ejemplo 1 - Barras horizontales: ¿qué región tiene mayor informalidad?
# -----------------------------------------------------------------------------
# CSV: 09a_tasa_informalidad_aportes.csv
# Operación: "rankear unidades" en un corte transversal -> barras horizontales
# ordenadas (checklist_visualizacion.md §1).
# =============================================================================

informalidad <- read_csv("data/inputs_md/09a_tasa_informalidad_aportes.csv",
                          show_col_types = FALSE)

ULTIMO_ANIO <- informalidad %>%
  mutate(anio = as.integer(str_sub(fecha, 1, 4))) %>%
  pull(anio) %>%
  max()

informalidad_anual <- informalidad %>%
  mutate(anio = as.integer(str_sub(fecha, 1, 4))) %>%
  filter(anio == ULTIMO_ANIO) %>%
  group_by(la_rioja_region) %>%
  summarise(tasa_inf_aportes = mean(tasa_inf_aportes, na.rm = TRUE), .groups = "drop")

informalidad_anual %>%
  ggplot(aes(x = tasa_inf_aportes,
             y = reorder(la_rioja_region, tasa_inf_aportes),
             fill = la_rioja_region)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = paste0(round(tasa_inf_aportes, 1), "%")),
            hjust = -0.15, size = 3.5, color = FUNDAR_TEXTO) +
  scale_fill_fundar_multi() +
  scale_x_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.15))) +
  theme_monitor_barras_h() +
  labs(
    title    = "El NOA tiene la mayor informalidad laboral del país, y La Rioja queda en el medio",
    subtitle = paste0("Asalariados sin aportes ni descuentos jubilatorios, como % de los asalariados. ",
                      "Promedio de las 4 ondas de ", ULTIMO_ANIO, "."),
    x        = "Tasa de informalidad (%)",
    y        = NULL,
    caption  = fuente_fundar("Fundar, con base en la EPH (INDEC). La Rioja es un dominio chico: se promedian las 4 ondas del año.")
  )

ggsave("clases/clase_3_pipeline_y_narrativa/plots/clase3_ej1_informalidad_barras.png",
       width = 11, height = 5)


# =============================================================================
# Ejemplo 2 - Scatter: ¿más estudios superiores va de la mano de más empleo?
# -----------------------------------------------------------------------------
# CSV: cruce de 12_mayor_25_superior.csv y 10_tasa_empleo.csv
# Operación: "correlacionar variables" -> scatter plot (checklist_visualizacion.md §1).
# =============================================================================

educacion <- read_csv("data/inputs_md/12_mayor_25_superior.csv", show_col_types = FALSE)
empleo    <- read_csv("data/inputs_md/10_tasa_empleo.csv",       show_col_types = FALSE)

educ_empleo <- educacion %>%
  select(fecha, la_rioja_region, porc_mayor_25_superior) %>%
  inner_join(
    empleo %>% select(fecha, la_rioja_region, tasa_empleo),
    by = c("fecha", "la_rioja_region")
  )

educ_empleo %>%
  ggplot(aes(x = porc_mayor_25_superior, y = tasa_empleo, color = la_rioja_region)) +
  geom_point(alpha = 0.5, size = 1.6) +
  geom_smooth(aes(group = la_rioja_region), method = "lm", se = FALSE, linewidth = 0.8) +
  scale_color_fundar_multi(name = "Región") +
  theme_monitor() +
  labs(
    title    = "En cada región, más población con estudios superiores coincide con más empleo",
    subtitle = "Cada punto es un trimestre (2007-2025). % de +25 años con superior completo vs. tasa de empleo.",
    x        = "Población +25 con estudios superiores completos (%)",
    y        = "Tasa de empleo (ocupados cada 100 hab.)",
    caption  = fuente_fundar("Fundar, con base en la EPH (INDEC). Correlación, no implica causalidad: ambas series crecen en el tiempo.")
  )

ggsave("clases/clase_3_pipeline_y_narrativa/plots/clase3_ej2_educacion_empleo_scatter.png",
       width = 9, height = 6)


# =============================================================================
# Ejemplo 3 - Small multiples: la trayectoria completa del NBI de La Rioja
# -----------------------------------------------------------------------------
# CSV: 13a_nbi_hogares.csv (el mismo de la Clase 2, con una pregunta y una
# marca distintas: la Clase 2 comparó DOS años con un Cleveland/dumbbell; acá
# se ve la SERIE completa, una dimensión por panel).
# Operación: "cambios en el tiempo, muchas categorías" -> small multiples
# (checklist_visualizacion.md §1).
# =============================================================================

nbi <- read_csv("data/inputs_md/13a_nbi_hogares.csv", show_col_types = FALSE)

nbi_lr_largo <- nbi %>%
  filter(la_rioja_region == "3. La Rioja") %>%
  select(fecha, starts_with("pct_hogares_NBI_"), -pct_hogares_NBI_TOT) %>%
  pivot_longer(starts_with("pct_hogares_NBI_"), names_to = "dimension", values_to = "pct") %>%
  mutate(
    fecha     = lubridate::yq(fecha),
    dimension = str_remove(dimension, "pct_hogares_NBI_"),
    dimension = recode(dimension,
                       HAC = "Hacinamiento",
                       VIV = "Vivienda inconveniente",
                       SAN = "Condiciones sanitarias",
                       ESC = "Escolaridad",
                       SUB = "Capacidad de subsistencia")
  )

nbi_lr_largo %>%
  ggplot(aes(x = fecha, y = pct)) +
  geom_line(color = unname(FUNDAR_MULTI["serie_3"]), linewidth = 0.7) +
  facet_wrap(~ dimension, ncol = 3) +
  scale_x_date(date_labels = "%Y", date_breaks = "6 years") +
  theme_monitor() +
  theme(strip.text = element_text(face = "bold", size = 9)) +
  labs(
    title    = "En La Rioja bajaron las cinco privaciones que componen el NBI, y hoy el hacinamiento es la que más pesa",
    subtitle = "% de hogares con cada privación (NBI). La Rioja, 2007-2025, trimestral.",
    x        = NULL,
    y        = "% de hogares",
    caption  = fuente_fundar(paste0("Fundar, con base en la EPH (INDEC). La Rioja es un dominio chico: ",
                                    "valores cercanos a 0,00% pueden reflejar el límite de la muestra, no ausencia de privación."))
  )

ggsave("clases/clase_3_pipeline_y_narrativa/plots/clase3_ej3_nbi_small_multiples.png",
       width = 11, height = 7)
