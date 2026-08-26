# =============================================================================
# CLASE 1 - EJERCICIO 1: la gramática, capa por capa
# -----------------------------------------------------------------------------
# Reconstruimos src/04_desoc.R desde cero, agregando UNA capa por vez.
#
# CÓMO USARLO: ejecutá cada PASO por separado (Ctrl+Enter línea por línea, o
# seleccionar el bloque y Ctrl+Enter) y MIRÁ el gráfico antes de pasar al
# siguiente. El objetivo no es llegar al gráfico final (ya existe) sino ver
# qué aporta exactamente cada línea.
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

# ---- Los datos --------------------------------------------------------------
# Un CSV de data/inputs_md/: la frontera entre el equipo de datos y el de
# comunicación. Tres regiones × 72 trimestres.

df <- read_csv("data/inputs_md/04_tasa_desoc.csv", show_col_types = FALSE)

glimpse(df)
# fecha            : el trimestre, como texto ("2007-Q1")
# la_rioja_region  : "1. Resto país" / "2. NOA-Resto" / "3. La Rioja"
# desoc, pea       : los totales ponderados con los que se calculó la tasa
# tasa_desoc       : el indicador


# ---- PASO 1: datos y mapeo estético, sin geometría --------------------------
# ggplot() + aes() declara QUÉ variable va a QUÉ propiedad visual.
# Todavía no dijimos con qué dibujarlo.
#
# PREGUNTA: ¿qué se ve? ¿Por qué el eje x está tan cargado?

ggplot(df, aes(x = fecha, y = tasa_desoc))


# ---- PASO 2: agregamos la geometría ----------------------------------------
# geom_line() = la marca. Una línea (1D).
#
# ¡ESTO VA A SALIR MAL! Mirá el resultado antes de seguir.
# PREGUNTA: ¿por qué dibuja una sola línea que sube y baja en zigzag?
#           ¿Qué información le falta a ggplot?

ggplot(df, aes(x = fecha, y = tasa_desoc)) +
  geom_line()


# ---- PASO 3: le decimos dónde cortar la línea -------------------------------
# `group` le dice a ggplot que hay TRES series, no una. Sin esto, une todos
# los puntos en el orden del eje x, saltando de una región a otra.

ggplot(df, aes(x = fecha, y = tasa_desoc,
               group = la_rioja_region)) +
  geom_line()


# ---- PASO 4: mapeamos la región al color ------------------------------------
# Ahora la región está codificada en DOS canales: agrupamiento y matiz.
#
# ATENCIÓN a la diferencia:
#   color = la_rioja_region   va DENTRO de aes()  → depende del dato
#   linewidth = 0.7           va FUERA de aes()   → es una constante
# Confundir esto es el error nº 1 de quien arranca con ggplot. Probá poner
# linewidth adentro de aes() y mirá qué pasa con la leyenda.

ggplot(df, aes(x = fecha, y = tasa_desoc,
               group = la_rioja_region,
               color = la_rioja_region)) +
  geom_line(linewidth = 0.7)


# ---- PASO 5: la escala del proyecto -----------------------------------------
# Hasta acá ggplot eligió los colores solo. scale_color_fundar_multi() impone
# la paleta institucional: dos tonos claros para el resto y el teal oscuro
# para La Rioja.
#
# PREGUNTA: ¿cuánto tardás en encontrar La Rioja antes y después de esta línea?

ggplot(df, aes(x = fecha, y = tasa_desoc,
               group = la_rioja_region,
               color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región")


# ---- PASO 6: el tema --------------------------------------------------------
# theme_monitor() no toca NINGÚN dato: solo decide cómo se ve lo que no es
# dato (fondo, grilla, tipografía, posición de la leyenda). Por eso vive en un
# archivo aparte y se aplica igual a los diez indicadores del monitor.
#
# ylim(0, 20) sí es una escala: fuerza que el eje y arranque en cero.

ggplot(df, aes(x = fecha, y = tasa_desoc,
               group = la_rioja_region,
               color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  ylim(0, 20) +
  theme_monitor()


# ---- PASO 7: la anotación ---------------------------------------------------
# Título, ejes y fuente. Esto es lo que separa un gráfico de exploración de un
# gráfico publicable. Volvemos sobre cómo redactarlos en la clase 3.

ggplot(df, aes(x = fecha, y = tasa_desoc,
               group = la_rioja_region,
               color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  ylim(0, 20) +
  theme_monitor() +
  labs(title   = "Tasa de desocupación",
       x       = "Año-Trimestre",
       y       = "Tasa de desocupación (%)",
       caption = fuente_fundar("EPH-INDEC"))

# Llegamos exactamente a src/04_desoc.R. Abrilo y comparalo.


# ---- EXTRA (si te sobra tiempo) ---------------------------------------------
# El eje x tiene 72 etiquetas de texto a 45°: es ilegible. Pasa porque `fecha`
# es un string ("2007-Q1") y ggplot trata cada valor como una categoría.
# Convirtiéndolo a fecha real, ggplot puede elegir marcas cada N años.
# (Esto lo retomamos en la clase 2 como caso de "visual cluttering".)

df %>%
  mutate(fecha = lubridate::yq(fecha)) %>%
  ggplot(aes(x = fecha, y = tasa_desoc,
             group = la_rioja_region, color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  ylim(0, 20) +
  theme_monitor() +
  labs(title = "Tasa de desocupación", x = NULL, y = "% de la PEA",
       caption = fuente_fundar("EPH-INDEC"))
