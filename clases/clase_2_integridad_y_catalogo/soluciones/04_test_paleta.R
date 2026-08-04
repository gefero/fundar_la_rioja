# =============================================================================
# CLASE 2 — EJERCICIO 4: SOLUCIÓN
# =============================================================================

library(tidyverse)
library(farver)
library(colorspace)
source("style/fundar_monitor_theme.R")

paleta <- c(
  "1. Resto país" = unname(FUNDAR_MULTI["serie_1"]),   # #A8DCC8
  "2. NOA-Resto"  = unname(FUNDAR_MULTI["serie_2"]),   # #C8C87A
  "3. La Rioja"   = unname(FUNDAR_MULTI["serie_3"])    # #2D6E6E
)

# ---- TEST 1: luminancia -----------------------------------------------------

lab <- farver::convert_colour(farver::decode_colour(paleta), from = "rgb", to = "lab")
tibble(region = names(paleta), hex = unname(paleta), luminancia = round(lab[, 1], 1))


# ---- TEST 2: ΔE 2000 --------------------------------------------------------

delta <- farver::compare_colour(
  from = farver::decode_colour(paleta), to = farver::decode_colour(paleta),
  from_space = "rgb", method = "cie2000")
dimnames(delta) <- list(names(paleta), names(paleta))
round(delta, 1)


# ---- TEST 3: daltonismo -----------------------------------------------------

paleta_deutan <- colorspace::deutan(paleta)
paleta_protan <- colorspace::protan(paleta)
paleta_tritan <- colorspace::tritan(paleta)

colorspace::swatchplot(list("Normal" = paleta, "Deuteranopia" = paleta_deutan,
                            "Protanopia" = paleta_protan, "Tritanopia" = paleta_tritan))

# El TODO: recalcular ΔE sobre la paleta simulada.
delta_deutan <- farver::compare_colour(
  from = farver::decode_colour(paleta_deutan),
  to   = farver::decode_colour(paleta_deutan),
  from_space = "rgb", method = "cie2000")
dimnames(delta_deutan) <- list(names(paleta), names(paleta))
round(delta_deutan, 1)

# Lo mismo para protanopia, que suele ser el caso más exigente:
delta_protan <- farver::compare_colour(
  from = farver::decode_colour(paleta_protan),
  to   = farver::decode_colour(paleta_protan),
  from_space = "rgb", method = "cie2000")
dimnames(delta_protan) <- list(names(paleta), names(paleta))
round(delta_protan, 1)


# =============================================================================
# CÓMO LEER LOS RESULTADOS
# =============================================================================
#
# NOTA: los valores exactos dependen de la versión de farver y del iluminante,
# así que lo que importa es el ORDEN DE MAGNITUD y la comparación entre pares,
# no el número al decimal.
#
# TEST 1 — Luminancia.
#   Los dos colores de contexto son CLAROS y La Rioja es OSCURO. Esa diferencia
#   de luminancia es grande y es la que produce el efecto pop-out que vimos en
#   la clase 1: encontrar La Rioja no requiere buscar, salta sola.
#   Entre "Resto país" y "NOA-Resto" la diferencia de luminancia es chica: se
#   distinguen por MATIZ (verde vs. oliva), no por brillo. Tiene sentido — son
#   las dos series de contexto y no compiten por la atención.
#
#   Conclusión: la jerarquía visual de la paleta está bien construida. Un
#   protagonista separado por luminancia, dos secundarios separados por matiz.
#
# TEST 2 — ΔE 2000.
#   El par crítico es "Resto país" vs "NOA-Resto": son los dos claros y los dos
#   tienen componente verde. Es el par de menor ΔE de la paleta.
#   Los pares que involucran La Rioja dan distancias mucho mayores, por la
#   diferencia de luminancia.
#   Si el par crítico queda por debajo de ~10, hay riesgo real de confusión
#   cuando las dos series se superponen o se cruzan.
#
# TEST 3 — Daltonismo.
#   Acá está el hallazgo importante, y es tranquilizador:
#   - La Rioja SOBREVIVE a todos los tipos de daltonismo. La luminancia no
#     depende del canal cromático afectado, así que el contraste claro/oscuro
#     se mantiene intacto. Lo que TIENE que destacarse, se sigue destacando.
#   - Los dos colores de contexto se acercan bajo deuteranopia y protanopia:
#     verde menta y amarillo oliva se vuelven más parecidos entre sí. Su ΔE cae
#     respecto de la visión tricromática.
#
#   Es decir: el riesgo NO está en perder al protagonista, está en no poder
#   separar las dos series secundarias. Es un problema menor —pero real si el
#   gráfico se usa para comparar Resto país con NOA.
#
#
# =============================================================================
# LA RECOMENDACIÓN
# =============================================================================
#
# Opción A (dejarla como está) es defendible y es la que menos costo tiene:
# la paleta cumple su función principal —destacar La Rioja— de forma robusta,
# incluso con daltonismo, y mantiene la identidad visual del Monitor de Fundar.
#
# La objeción es acotada y hay que registrarla: en los gráficos donde la
# comparación relevante es "Resto país vs. NOA-Resto" (y no "La Rioja vs. el
# resto"), las dos series de contexto son demasiado parecidas, sobre todo para
# lectores con deuteranopia o protanopia.
#
# Recomendación concreta, en orden de esfuerzo:
#
# 1. ADOPTAR LA OPCIÓN C como default del tema: agregar grosor de línea
#    redundante para La Rioja. No cambia ningún color, no toca la identidad
#    visual, y hace que el énfasis no dependa solo del color. El tema viejo
#    (style/fundar_larioja_theme.R) ya tiene scale_linewidth_larioja() haciendo
#    exactamente esto: se puede portar a fundar_monitor_theme.R.
#
# 2. Si en algún gráfico la comparación principal es Resto país vs. NOA-Resto,
#    ahí sí ajustar el segundo color hacia un matiz más lejano del verde.
#
# 3. Documentar en el README el resultado de esta auditoría, para que la próxima
#    persona que toque la paleta sepa qué criterios tiene que respetar.

df <- read_csv("data/inputs_md/04_tasa_desoc.csv", show_col_types = FALSE) %>%
  mutate(fecha = lubridate::yq(fecha))

# La opción recomendada, para comparar a ojo:
df %>%
  ggplot(aes(x = fecha, y = tasa_desoc,
             group = la_rioja_region, color = la_rioja_region,
             linewidth = la_rioja_region)) +
  geom_line() +
  scale_color_fundar_multi(name = NULL) +
  scale_linewidth_manual(values = c(0.6, 0.6, 1.2), guide = "none") +
  ylim(0, 20) +
  theme_monitor() +
  labs(title = "Opción C — color + grosor (redundancia)",
       x = NULL, y = "% de la PEA")
