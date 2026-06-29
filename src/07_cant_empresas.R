library(tidyverse)
source('./style/fundar_monitor_theme.R')

df <- read_csv("./data/inputs_md/07_serie_empresas_por_jurisdiccion.csv")

df <- df %>%
  mutate(la_rioja_aglo = if_else(jurisdiccion == "La Rioja", "La Rioja", "Resto"),
         la_rioja_region = case_when(
           jurisdiccion == "La Rioja" ~ "3. La Rioja", 
           jurisdiccion %in% 
             c("Catamarca", "Jujuy", "Salta","Santiago del Estero", "Tucumán") ~ "2. NOA-Resto",
           TRUE ~ "1. Resto país"))

df %>%
 # mutate(la_rioja = if_else(jurisdiccion == "La Rioja", "3. La Rioja", "1. Resto")) %>%
  ggplot(aes(x = fecha, 
             y = empresas,
             group = jurisdiccion,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Jurisdicción") +
  theme_monitor() +
  scale_x_date(date_labels = "%m-%Y") +
  labs(
    title   = "Cantidad de empresas por jurisdicción",
    x       = "Fecha",
    y       = "Cantidad de empresas",
    caption = fuente_fundar("Fundar, con base en datos de SRT.")
  )

ggsave('./outputs/plots/11_empresas_jurisdiccion.png', width = 12, height = 7)