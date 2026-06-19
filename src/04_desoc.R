## 04. Tasa de desocupación

library(tidyverse)
source('./style/fundar_larioja_theme.R')

df <- read_csv('./data/inputs_md/04_tasa_desoc.csv')

df %>%
  ggplot(aes(x = fecha, y = tasa_desoc,
             group = AGLOMERADO,
             color = la_rioja_region,
             linewidth = la_rioja_region)) +
  geom_line() +
  scale_color_larioja() +
  scale_linewidth_larioja() +
  labs(x = "Año-Trimestre",
       y = "Tasa de desocupación (%)",
       caption = "Fuente: EPH-INDEC")

