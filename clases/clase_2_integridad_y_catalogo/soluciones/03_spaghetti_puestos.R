# =============================================================================
# CLASE 2 — EJERCICIO 3: SOLUCIÓN
# =============================================================================

library(tidyverse)
source("style/fundar_monitor_theme.R")

df <- read_csv("data/inputs_md/05_puestos_asalariados_privados.csv",
               show_col_types = FALSE)

# ---- Índice base 100 --------------------------------------------------------
# Se agrupa POR JURISDICCIÓN: cada provincia se divide por SU PROPIO primer
# valor. arrange() antes del group_by() garantiza que first() tome el mes
# más antiguo y no una fila cualquiera.

df_idx <- df %>%
  arrange(jurisdiccion, fecha) %>%
  group_by(jurisdiccion) %>%
  mutate(indice = puestos_miles / first(puestos_miles) * 100) %>%
  ungroup()

df_idx %>% filter(fecha == min(fecha)) %>% count(indice)   # 24 filas en 100

df_resto    <- df_idx %>% filter(jurisdiccion != "La Rioja")
df_la_rioja <- df_idx %>% filter(jurisdiccion == "La Rioja")


# ---- El spaghetti -----------------------------------------------------------
# Primero el contexto (queda abajo), después la protagonista (queda encima).

ggplot() +
  geom_line(data = df_resto,
            aes(x = fecha, y = indice, group = jurisdiccion),
            color = FUNDAR_GRILLA, linewidth = 0.4) +
  geom_line(data = df_la_rioja,
            aes(x = fecha, y = indice),
            color = unname(FUNDAR_MULTI["serie_3"]), linewidth = 1.1) +
  geom_hline(yintercept = 100, linetype = "dotted",
             color = FUNDAR_GRIS, linewidth = 0.4) +
  geom_text(data = df_la_rioja %>% filter(fecha == max(fecha)),
            aes(x = fecha, y = indice, label = "La Rioja"),
            hjust = -0.15, size = 3.2, fontface = "bold",
            color = unname(FUNDAR_MULTI["serie_3"])) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years",
               expand = expansion(mult = c(0.02, 0.10))) +
  coord_cartesian(clip = "off") +
  theme_monitor() +
  labs(
    title    = "El empleo privado en La Rioja creció menos que en la mayoría de las provincias",
    subtitle = paste0("Puestos asalariados privados registrados. Índice base 100 = ",
                      format(min(df$fecha), "%b-%Y"),
                      ". Cada línea gris es una jurisdicción."),
    x        = NULL,
    y        = "Índice (base 100)",
    caption  = fuente_fundar("Fundar, con base en el SIPA (Ministerio de Capital Humano).")
  )

ggsave("outputs/plots/clase2_spaghetti_puestos.png", width = 11, height = 6)


# ---- Verificación del hallazgo ----------------------------------------------
# El ranking de crecimiento acumulado punta a punta:

df_idx %>%
  filter(fecha == max(fecha)) %>%
  arrange(desc(indice)) %>%
  mutate(puesto = row_number()) %>%
  select(puesto, jurisdiccion, indice)

# La Rioja queda 17ª de 24, con un índice de ~107: +7% en 17 años. Neuquén
# lidera con +68% (Vaca Muerta) y tres provincias están por debajo de 100
# (Santa Cruz, Chubut, San Luis).


# =============================================================================
# RESPUESTAS
# =============================================================================
#
# 1. ¿Por qué La Rioja tiene que dibujarse DESPUÉS?
#    Porque ggplot dibuja las capas en el orden en que se escriben, y la última
#    queda arriba. Si La Rioja se dibujara primero, las 23 líneas grises la
#    taparían en cada cruce. Es el mismo problema de oclusión que en el repo se
#    resuelve con los prefijos "1."/"2."/"3." de la_rioja_region: al forzar el
#    orden alfabético del factor, La Rioja se dibuja última.
#    Acá lo resolvimos con dos dataframes y dos capas, que es la forma canónica
#    del spaghetti plot: separar explícitamente contexto de protagonista.
#
# 2. Al pasar a índice base 100, ¿qué información perdiste?
#    EL TAMAÑO. En el gráfico indexado, La Rioja (27 mil puestos) y Buenos Aires
#    (1.750 mil) ocupan el mismo espacio visual. Un lector desprevenido puede
#    concluir que son comparables en magnitud, y no lo son: son dos órdenes de
#    magnitud de diferencia.
#
#    Es un caso interesante porque el índice RESUELVE un problema de integridad
#    (los niveles aplastados contra el cero) y CREA otro (la falsa equivalencia
#    de escala). No hay transformación gratis.
#
#    Cómo recuperarlo sin romper el gráfico:
#    - decir el nivel de partida en el subtítulo ("La Rioja partía de 27 mil
#      puestos");
#    - mapear el grosor de las líneas grises al tamaño de la provincia (canal
#      redundante, con moderación);
#    - acompañar con una tabla o un segundo gráfico de niveles.
#
# 3. ¿Cuál para el informe y cuál para el anexo?
#    El spaghetti para el informe: responde en un vistazo la pregunta "¿cómo le
#    fue a La Rioja comparada con el resto?" y da contexto con las 24 unidades.
#    El facetado actual para el anexo: sirve para consultar el nivel de cada
#    región, que es otra pregunta —y una que el spaghetti no puede contestar.
#
# 4. EXTRA: ¿qué pasa si cambio la base?
#    La conclusión SE MUEVE, y bastante. Con base enero-2009 (arranque de la
#    serie) La Rioja queda 17ª. Con base enero-2016 el ranking cambia, porque
#    cada provincia tuvo trayectorias distintas en el medio.
#
#    La lección para comunicar: EL AÑO BASE ES UNA DECISIÓN, no un dato. Hay que
#    (a) elegirlo con un criterio explicable —el inicio de la serie, un cambio
#    de régimen, un año "normal"—, (b) declararlo siempre en el subtítulo, y
#    (c) chequear que la conclusión no dependa exclusivamente de esa elección.
#    Si cambia con la base, la conclusión honesta es más débil de lo que parece.
