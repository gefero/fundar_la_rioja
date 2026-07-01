## 04. Tasa de desocupación

library(tidyverse)
source('./style/fundar_monitor_theme.R')

df <- read_csv('./data/inputs_md/04_tasa_desoc.csv')

df_plot <- df %>% mutate(la_rioja_region = factor(la_rioja_region))

df_plot %>%
  ggplot(aes(x = fecha, y = tasa_desoc,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  ylim(0,20) +
  theme_monitor() +
  labs(title   = "Tasa de desocupación",
       x       = "Año-Trimestre",
       y       = "Tasa de desocupación (%)",
       caption = fuente_fundar("EPH-INDEC"))

ggsave('./outputs/plots/04_desoc.png', width=12, height=8)
