## 09a. Tasa de informalidad aportes

library(tidyverse)
source('./style/fundar_larioja_theme.R')

df <- read_csv('./data/inputs_md/09a_tasa_informalidad_aportes.csv')

df %>%
  ggplot(aes(x = fecha, y = tasa_inf_aportes,
             group = AGLOMERADO,
             color = la_rioja_region,
             linewidth = la_rioja_region)) +
  geom_line() +
  scale_color_larioja() +
  scale_linewidth_larioja() +
  labs(x = "Año-Trimestre",
       y = "Tasa de informalidad por aportes a SS (%)",
       caption = "Fuente: EPH-INDEC")

ggsave('./outputs/plots/09a_informalidad_aportes.png', width=12, height=8)
