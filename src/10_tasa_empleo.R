## 10- Tasa de empleo

library(tidyverse)
source('./style/fundar_monitor_theme.R')

df <- read_csv('./data/inputs_md/10_tasa_empleo.csv')

df_plot <- df %>% mutate(la_rioja_region = factor(la_rioja_region))
df_plot %>%
  ggplot(aes(x = fecha, y = tasa_empleo,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Región") +
  theme_monitor() +
  labs(title   = "Tasa de empleo",
       x       = "Año-Trimestre",
       y       = "Tasa de empleo (ocupados cada 100 hab.)",
       caption = fuente_fundar("EPH-INDEC"))

ggsave('./outputs/plots/10_tasa_empleo.png', width=12, height=8)
