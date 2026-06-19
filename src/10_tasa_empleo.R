## 10- Tasa de empleo

library(tidyverse)
source('./style/fundar_larioja_theme.R')

df <- read_csv('./data/inputs_md/10_tasa_empleo.csv')

df %>%
  ggplot(aes(x = fecha, y = tasa_empleo,
             group = AGLOMERADO,
             color = la_rioja_region,
             linewidth = la_rioja_region)) +
  geom_line() +
  scale_color_larioja() +
  scale_linewidth_larioja() +
  labs(x = "Año-Trimestre",
       y = "Tasa de informalidad por aportes a SS (%)",
       caption = "Fuente: EPH-INDEC")
