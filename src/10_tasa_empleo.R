## 10- Tasa de empleo

library(tidyverse)
source('./style/fundar_monitor_theme.R')

df <- read_csv('./data/inputs_md/10_tasa_empleo.csv')

df_plot <- df %>% mutate(la_rioja_region = factor(la_rioja_region))
pts     <- puntos_etiqueta(df_plot, fecha, tasa_empleo, AGLOMERADO)

df_plot %>%
  ggplot(aes(x = fecha, y = tasa_empleo,
             group = AGLOMERADO,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  geom_text(data = pts,
            aes(label = round(tasa_empleo, 1)),
            size = 2.5, vjust = -0.8, show.legend = FALSE) +
  scale_color_fundar_multi(name = "Región") +
  labs(title   = "Tasa de empleo",
       x       = "Año-Trimestre",
       y       = "Tasa de empleo (ocupados cada 100 hab.)",
       caption = fuente_fundar("EPH-INDEC"))

ggsave('./outputs/plots/10_tasa_empleo.png', width=12, height=8)