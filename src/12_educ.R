## 12.% de < 25 on NED alto

library(tidyverse)
source('./style/fundar_larioja_theme.R')

df <- read_csv('./data/inputs_md/12_mayor_25_superior.csv')

df %>% 
  ggplot(aes(x = fecha, y = porc_mayor_25_superior,
           group = AGLOMERADO,
           color = la_rioja_region,
           linewidth = la_rioja_region)) +
  geom_line() +
  scale_color_larioja() +
  scale_linewidth_larioja() +
  labs(x = "Año-Trimestre",
       y = "% de personas mayores de 25 años con estudios superiores completos",
       caption = "Fuente: EPH-INDEC")

