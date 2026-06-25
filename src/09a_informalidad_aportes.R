## 09a. Tasa de informalidad aportes

library(tidyverse)
source('./style/fundar_monitor_theme.R')

df <- read_csv('./data/inputs_md/09a_tasa_informalidad_aportes.csv')

df_plot <- df %>% mutate(la_rioja_region = factor(la_rioja_region))
pts     <- puntos_etiqueta(df_plot, fecha, tasa_inf_aportes, AGLOMERADO) %>%
  filter(la_rioja_region == "3. La Rioja")

df_plot %>%
  ggplot(aes(x = fecha, y = tasa_inf_aportes,
             group = AGLOMERADO,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  geom_text(data = pts,
            aes(label = round(tasa_inf_aportes, 1)),
            size = 3.5, vjust = -0.8, show.legend = FALSE) +
  scale_color_fundar_multi(name = "Región") +
  labs(title   = "Tasa de informalidad por aportes a la seguridad social",
       x       = "Año-Trimestre",
       y       = "Tasa de informalidad por aportes a SS (%)",
       caption = fuente_fundar("EPH-INDEC"))

ggsave('./outputs/plots/09a_informalidad_aportes.png', width=12, height=8)
