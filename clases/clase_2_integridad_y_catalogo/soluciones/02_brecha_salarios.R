# =============================================================================
# CLASE 2 - EJERCICIO 2: SOLUCIÓN
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/03b_salarios_registrados_EPH.csv",
               show_col_types = FALSE)

df_lr <- df %>%
  filter(la_rioja_region == "3. La Rioja") %>%
  mutate(fecha = lubridate::yq(fecha)) %>%
  pivot_wider(names_from = sector, values_from = salario_promedio) %>%
  mutate(
    brecha = Privado - `Público`,
    signo  = if_else(brecha >= 0, "Privado por encima", "Público por encima")
  )

count(df_lr, signo)   # 57 trimestres con el privado arriba, 15 con el público


df_lr %>%
  filter(fecha >= as.Date("2022-01-01"), fecha <= as.Date("2026-12-31")) %>%
  ggplot(aes(x = fecha)) +
  geom_ribbon(aes(ymin = pmin(Privado, `Público`),
                  ymax = pmax(Privado, `Público`),
                  fill = signo),
              alpha = 0.35) +
  geom_line(aes(y = Privado,   color = "Privado"), linewidth = 0.7) +
  geom_line(aes(y = `Público`, color = "Público"), linewidth = 0.7) +
  scale_color_manual(values = FUNDAR_SECTOR, name = NULL) +
  scale_fill_manual(values = c("Privado por encima" = FUNDAR_VERDE,
                               "Público por encima" = FUNDAR_ROSA),
                    name = NULL) +
  scale_y_continuous(
    limits = c(0, NA),
    labels = scales::label_number(big.mark = ".", decimal.mark = ",", prefix = "$")
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme_monitor() +
  labs(
    title    = "La brecha a favor del sector privado se ensanchó desde 2021",
    subtitle = "Salario promedio de asalariados registrados. Aglomerado La Rioja, pesos corrientes. 2022-2026.",
    x        = NULL,
    y        = "Pesos corrientes",
    caption  = fuente_fundar("Fundar, con base en la EPH (INDEC).")
  )

ggsave("clases/clase_2_integridad_y_catalogo/plots/clase2_brecha_salarios.png", width = 11, height = 6)


# ---- Variante recomendada para publicar: la brecha en % ---------------------
# El área en pesos corrientes ENGAÑA: crece con la inflación aunque la brecha
# relativa no cambie. La versión honesta grafica la brecha como porcentaje.

df_lr %>%
  mutate(brecha_pct = (Privado / `Público` - 1) * 100) %>%
  ggplot(aes(x = fecha, y = brecha_pct)) +
  geom_hline(yintercept = 0, color = FUNDAR_TEXTO, linewidth = 0.4) +
  geom_area(aes(fill = if_else(brecha_pct >= 0, "pos", "neg")), alpha = 0.4) +
  geom_line(color = FUNDAR_TEXTO, linewidth = 0.6) +
  geom_vline(xintercept = as.Date("2016-01-01"),
             linetype = "dashed", color = FUNDAR_GRIS, linewidth = 0.4) +
  scale_fill_manual(values = c(pos = FUNDAR_VERDE, neg = FUNDAR_ROSA), guide = "none") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  theme_monitor() +
  labs(title = "Brecha salarial privado/público, en porcentaje",
       subtitle = "Cuánto más gana un asalariado registrado privado que uno público. Aglomerado La Rioja.",
       x = NULL, y = "Brecha (%)",
       caption = fuente_fundar("Fundar, con base en la EPH (INDEC)."))


# =============================================================================
# RESPUESTAS
# =============================================================================
#
# 1. ¿Por qué hay que marcar el quiebre de 2015/2016?
#    Por dos razones acumuladas, las dos documentadas en el README:
#    (a) La EPH cambió el método de imputación de ingresos. Antes de ~2016 no
#        publicaba PONDIIO (el ponderador de ingreso que corrige la no
#        respuesta), así que el cálculo usa PONDERA como fallback. Son dos
#        ponderaciones distintas: los niveles no son estrictamente comparables.
#    (b) La EPH estuvo INTERRUMPIDA entre 2015-T3 y 2016-T1. Ahí no hay dato, y
#        la línea que cruza ese hueco es una interpolación visual, no un dato.
#
#    Sin la marca, el lector lee una serie continua donde hay dos series.
#
# 2. ¿Qué gana y qué pierde cada versión?
#    El gráfico actual (facetado por región) gana COMPARACIÓN TERRITORIAL: se ve
#    si el patrón de La Rioja es propio o es el patrón de todo el país. Pierde
#    precisión sobre la brecha: con los paneles en `scales = "free_y"`, las
#    distancias verticales no son comparables entre paneles.
#    La versión de hoy gana la brecha (el área la muestra sola, de forma
#    preatentiva, y los cambios de signo saltan a la vista con el cambio de
#    color) y pierde el contexto de las otras dos regiones.
#    No hay ganador: responden a preguntas distintas. La del informe de
#    Argendata es que si la pregunta ES la brecha, hay que usar el área.
#
# 3. El eje Y está en pesos corrientes. ¿Qué le agregarías?
#    Este es el punto importante del ejercicio. En pesos corrientes:
#    - las dos series suben aunque el poder adquisitivo caiga;
#    - y peor: el ÁREA ENTRE ELLAS crece mecánicamente con la inflación aunque
#      la brecha relativa no cambie. Una brecha del 8% sobre $1.000 dibuja un
#      área invisible; la misma brecha del 8% sobre $800.000 dibuja una franja
#      enorme. El gráfico exagera la evolución de la brecha por construcción.
#
#    Es un caso de FACTOR DE MENTIRA que no se ve a simple vista, y es
#    exactamente la slide 159 del deck: "en las series de tiempo monetarias,
#    casi siempre es mejor usar unidades estandarizadas en lugar de nominales".
#
#    Las opciones, de menos a más correcta:
#    a) Aclararlo en el subtítulo (mínimo indispensable).
#    b) Graficar la brecha en PORCENTAJE, como en la variante de arriba. Es
#       inmune a la inflación y es lo que hay que publicar.
#    c) Deflactar ambas series por IPC. Requiere sumar una serie de IPC al
#       repositorio: queda como pendiente del proyecto (el indicador 03 tiene
#       el mismo problema).
#
#    Los números: la brecha era ~8% en 2007-2009, se achicó hasta darse vuelta
#    en 2020 (el público pasó a ganar más), y en 2025-Q4 llegó a ~35% a favor
#    del privado. Esa es la historia - y en el gráfico en pesos corrientes es
#    casi imposible de leer.
#
# 4. EXTRA: ¿por qué el informe prefiere el área a una tercera línea?
#    Porque la tercera línea (a) agrega un elemento gráfico más, (b) obliga a
#    extender el eje Y hacia valores negativos, lo que achata las dos series
#    originales, y (c) fuerza al lector a mirar una serie derivada en vez de
#    percibir la brecha directamente. El informe muestra un caso donde una
#    reducción de 12 puntos queda "casi imperceptible" al graficarse como línea
#    de brecha, y salta a la vista como área.
#    Contrapunto: si la brecha es MUY chica en relación a los niveles, el área
#    es una franja fina y ahí sí conviene la serie derivada (o el porcentaje).
