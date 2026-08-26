# =============================================================================
# CLASE 2 - EJERCICIO 2: la brecha implícita
# -----------------------------------------------------------------------------
# PREGUNTA: ¿se agrandó o se achicó la brecha salarial entre el sector público
#           y el privado en La Rioja?
#
# El informe de Argendata (págs. 19-20) recomienda NO graficar la brecha
# calculada como una tercera serie, sino dejar que el ÁREA ENTRE LAS DOS LÍNEAS
# la muestre sola: se percibe de forma preatentiva y no agrega elementos al
# gráfico.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/03b_salarios_registrados_EPH.csv",
               show_col_types = FALSE)

glimpse(df)   # fecha, la_rioja_region, sector ("Público"/"Privado"), salario_promedio


# ---- PASO 1: La Rioja, en formato ancho -------------------------------------
# geom_ribbon() necesita ymin e ymax EN LA MISMA FILA. Hoy los dos sectores
# están en filas distintas: hay que pivotear a ancho.
#
# TODO: completá el pivot_wider().

df_lr <- df %>%
  filter(la_rioja_region == "3. La Rioja") %>%
  mutate(fecha = lubridate::yq(fecha)) %>%
  pivot_wider(names_from  = ______,      # <-- TODO: ¿qué columna se abre en columnas?
              values_from = ______)      # <-- TODO: ¿qué columna llena las celdas?

glimpse(df_lr)   # debería tener: fecha, la_rioja_region, Privado, Público


# ---- PASO 2: quién está arriba ----------------------------------------------
# Coloreamos el área según el signo de la brecha: no siempre gana el mismo
# sector, y eso es parte del hallazgo.

df_lr <- df_lr %>%
  mutate(
    brecha    = Privado - `Público`,
    signo     = if_else(brecha >= 0, "Privado por encima", "Público por encima")
  )

# ¿Cuántos trimestres de cada lado?
count(df_lr, signo)


# ---- PASO 3: el gráfico -----------------------------------------------------
# Capas, de abajo hacia arriba:
#   1. el área entre las dos series (la brecha implícita)
#   2. las dos líneas
#   3. la marca del quiebre metodológico

df_lr %>%
  ggplot(aes(x = fecha)) +

  # 1. LA BRECHA IMPLÍCITA
  # TODO: completá ymin e ymax con las dos columnas de sector.
  geom_ribbon(aes(ymin = pmin(______, ______),      # <-- TODO
                  ymax = pmax(______, ______),      # <-- TODO
                  fill = signo),
              alpha = 0.35) +

  # 2. LAS DOS LÍNEAS
  geom_line(aes(y = Privado,   color = "Privado"), linewidth = 0.7) +
  geom_line(aes(y = `Público`, color = "Público"), linewidth = 0.7) +

  # 3. EL QUIEBRE METODOLÓGICO (2015-2016)
  # La EPH cambió el método de imputación de ingresos y estuvo interrumpida
  # entre 2015-T3 y 2016-T1. Los niveles a ambos lados NO son comparables.
  geom_vline(xintercept = as.Date("2016-01-01"),
             linetype = "dashed", color = FUNDAR_GRIS, linewidth = 0.4) +

  scale_color_manual(values = FUNDAR_SECTOR, name = NULL) +
  scale_fill_manual(values = c("Privado por encima" = FUNDAR_VERDE,
                               "Público por encima" = FUNDAR_ROSA),
                    name = NULL) +
  scale_y_continuous(
    limits = c(0, NA),                                  # el eje arranca en cero
    labels = scales::label_number(big.mark = ".", decimal.mark = ",", prefix = "$")
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  theme_monitor() +
  labs(
    title    = "TODO: escribilo vos - ¿qué le pasó a la brecha?",
    subtitle = "Salario promedio de asalariados registrados. Aglomerado La Rioja, pesos corrientes.",
    x        = NULL,
    y        = "Pesos corrientes",
    caption  = fuente_fundar(
      "Fundar, con base en la EPH (INDEC). Línea punteada: cambio de metodología de ingresos de la EPH (2015-2016); los niveles a ambos lados no son estrictamente comparables."
    )
  )

# ggsave("clases/clase_2_integridad_y_catalogo/plots/clase2_brecha_salarios.png", width = 11, height = 6)


# =============================================================================
# PREGUNTAS
# =============================================================================
# 1. ¿Por qué hay que marcar el quiebre de 2015/2016?
#    (Pista: README.md, nota del indicador 03b. Antes de ~2016 la EPH no
#     publicaba PONDIIO y se usa PONDERA como ponderador de fallback.)
#
# 2. Compará con outputs/plots/03b_salarios_registrados_EPH.png (el gráfico
#    actual, facetado por región). ¿Qué gana y qué pierde cada versión?
#
# 3. El eje Y está en PESOS CORRIENTES. Mirando la slide 159 del deck
#    ("en las series de tiempo monetarias, casi siempre es mejor usar unidades
#    estandarizadas en lugar de nominales"): ¿qué le agregarías a este gráfico
#    antes de publicarlo?
#
# 4. EXTRA: probá graficar la brecha como una TERCERA LÍNEA (Privado - Público)
#    en un gráfico aparte. ¿Se ve mejor o peor que el área? ¿Por qué el informe
#    prefiere el área?
