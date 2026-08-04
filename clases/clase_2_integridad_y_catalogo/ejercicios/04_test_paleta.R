# =============================================================================
# CLASE 2 — EJERCICIO 4: auditar nuestra propia paleta
# -----------------------------------------------------------------------------
# FUNDAR_MULTI (style/fundar_monitor_theme.R:25) se eligió por criterio
# estético, replicando el Monitor Mensual de Empresas. Nunca se auditó con los
# criterios que vimos hoy. Vamos a hacerlo.
#
# (src/test_escalas.R es un intento a medio hacer de exactamente esto: carga las
#  paletas de ColorBrewer y ahí queda. Este ejercicio lo completa.)
#
# Se hace TODOS JUNTOS: el resultado es una decisión de proyecto.
# =============================================================================

library(tidyverse)
library(farver)       # distancias perceptuales entre colores
library(colorspace)   # simulación de daltonismo
source("style/fundar_monitor_theme.R")

# Los tres colores regionales que efectivamente usamos en los gráficos.
paleta <- c(
  "1. Resto país" = unname(FUNDAR_MULTI["serie_1"]),   # #A8DCC8 verde menta claro
  "2. NOA-Resto"  = unname(FUNDAR_MULTI["serie_2"]),   # #C8C87A amarillo oliva
  "3. La Rioja"   = unname(FUNDAR_MULTI["serie_3"])    # #2D6E6E teal oscuro
)

colorspace::swatchplot(paleta)


# =============================================================================
# TEST 1 — Contraste de luminancia
# =============================================================================
# La luminancia (el canal "L" del espacio Lab) es lo que hace que una serie
# salte a la vista. Va de 0 (negro) a 100 (blanco).

lab <- farver::convert_colour(farver::decode_colour(paleta),
                              from = "rgb", to = "lab")

tibble(
  region     = names(paleta),
  hex        = unname(paleta),
  luminancia = round(lab[, 1], 1)
)

# PREGUNTA: ¿cuánta diferencia de luminancia hay entre La Rioja y las otras
#           dos? ¿Y entre "Resto país" y "NOA-Resto" entre sí?
#           ¿Es eso deliberado o accidental?


# =============================================================================
# TEST 2 — Distancia perceptual (ΔE 2000)
# =============================================================================
# ΔE mide cuán distintos se PERCIBEN dos colores. Regla práctica:
#   ΔE < 5   → prácticamente indistinguibles
#   ΔE < 10  → riesgoso para series superpuestas en un gráfico
#   ΔE > 20  → cómodamente distinguibles

delta <- farver::compare_colour(
  from       = farver::decode_colour(paleta),
  to         = farver::decode_colour(paleta),
  from_space = "rgb",
  method     = "cie2000"
)
dimnames(delta) <- list(names(paleta), names(paleta))
round(delta, 1)

# PREGUNTA: ¿cuál es el par MÁS PARECIDO de la paleta? ¿Supera el umbral de 10?


# =============================================================================
# TEST 3 — Daltonismo
# =============================================================================
# ~8% de los varones tiene alguna forma de daltonismo. Si dos series de un
# gráfico se vuelven el mismo color, ese lector no puede leerlo.

paleta_deutan <- colorspace::deutan(paleta)   # deuteranopia (la más frecuente)
paleta_protan <- colorspace::protan(paleta)   # protanopia
paleta_tritan <- colorspace::tritan(paleta)   # tritanopia (rara)

colorspace::swatchplot(list(
  "Normal"       = paleta,
  "Deuteranopia" = paleta_deutan,
  "Protanopia"   = paleta_protan,
  "Tritanopia"   = paleta_tritan
))

# TODO: calculá el ΔE de la paleta simulada bajo deuteranopia, igual que en el
#       TEST 2, y compará con la matriz de arriba. ¿Algún par baja del umbral?

delta_deutan <- farver::compare_colour(
  from       = farver::decode_colour(______),   # <-- TODO
  to         = farver::decode_colour(______),   # <-- TODO
  from_space = "rgb",
  method     = "cie2000"
)
dimnames(delta_deutan) <- list(names(paleta), names(paleta))
round(delta_deutan, 1)


# =============================================================================
# TEST 4 — La prueba definitiva: mirarlo
# =============================================================================
# Los números están bien, pero lo que importa es si el gráfico se lee.

df <- read_csv("data/inputs_md/04_tasa_desoc.csv", show_col_types = FALSE) %>%
  mutate(fecha = lubridate::yq(fecha))

grafico <- function(colores, titulo) {
  df %>%
    ggplot(aes(x = fecha, y = tasa_desoc,
               group = la_rioja_region, color = la_rioja_region)) +
    geom_line(linewidth = 0.8) +
    scale_color_manual(values = colores, name = NULL) +
    ylim(0, 20) +
    theme_monitor() +
    labs(title = titulo, x = NULL, y = "% de la PEA")
}

grafico(paleta,        "Visión tricromática")
grafico(paleta_deutan, "Simulación de deuteranopia")
grafico(paleta_protan, "Simulación de protanopia")

# PREGUNTA: en las simulaciones, ¿podés seguir distinguiendo las tres series?
#           ¿Y encontrar La Rioja?


# =============================================================================
# LA DECISIÓN DE PROYECTO
# =============================================================================
# Con los números a la vista, tenemos tres opciones. Discutámoslas:
#
# A) DEJARLA COMO ESTÁ.
#    Argumento: el contraste de luminancia de La Rioja sobrevive a cualquier
#    tipo de daltonismo (la luminancia no depende del canal cromático), y La
#    Rioja es lo único que TIENE que destacarse.
#
# B) AJUSTAR los dos colores de contexto para separarlos más entre sí.
#    Costo: nos alejamos de la identidad visual del Monitor de Fundar.
#
# C) AGREGAR UN CANAL REDUNDANTE: que La Rioja además tenga la línea más
#    gruesa. Así el énfasis no depende SOLO del color.
#    (El tema viejo, style/fundar_larioja_theme.R, ya tiene
#     scale_linewidth_larioja() haciendo exactamente esto.)
#
# Probá la opción C:

df %>%
  ggplot(aes(x = fecha, y = tasa_desoc,
             group = la_rioja_region,
             color = la_rioja_region,
             linewidth = la_rioja_region)) +
  geom_line() +
  scale_color_fundar_multi(name = NULL) +
  scale_linewidth_manual(values = c(0.6, 0.6, 1.2), guide = "none") +
  ylim(0, 20) +
  theme_monitor() +
  labs(title = "Opción C — color + grosor (redundancia)",
       x = NULL, y = "% de la PEA")

# ¿Con cuál nos quedamos? La respuesta va al README del proyecto.
