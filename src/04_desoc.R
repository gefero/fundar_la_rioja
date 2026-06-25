## 04. Tasa de desocupación

library(tidyverse)
source('./style/fundar_monitor_theme.R')

df <- read_csv('./data/inputs_md/04_tasa_desoc.csv')

df_plot <- df %>% mutate(la_rioja_region = factor(la_rioja_region))
pts     <- puntos_etiqueta(df_plot, fecha, tasa_desoc, AGLOMERADO)

df_plot %>%
  ggplot(aes(x = fecha, y = tasa_desoc,
             group = AGLOMERADO,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  geom_text(data = pts,
            aes(label = round(tasa_desoc, 1)),
            size = 2.5, vjust = -0.8, show.legend = FALSE) +
  scale_color_fundar_multi(name = "Región") +
  labs(title   = "Tasa de desocupación",
       x       = "Año-Trimestre",
       y       = "Tasa de desocupación (%)",
       caption = fuente_fundar("EPH-INDEC"))

ggsave('./outputs/plots/04_desoc.png', width=12, height=8)
