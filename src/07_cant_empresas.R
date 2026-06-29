library(tidyverse)
source('./style/fundar_monitor_theme.R')

df <- read_csv("./data/inputs_md/07_serie_empresas_por_jurisdiccion.csv")

noa <- c("Catamarca", "Jujuy", "Salta","Santiago del Estero", "Tucumán", "La Rioja")

df <- df %>%
  mutate(
    noa_region = if_else(jurisdiccion %in% noa, "NOA", "Resto"),
    la_rioja_region = case_when(
           jurisdiccion == "La Rioja" ~ "3. La Rioja", 
           jurisdiccion %in% noa & jurisdiccion != "La Rioja" ~ "2. NOA-Resto",
           TRUE ~ "1. Resto país")
    )

df %>%
  group_by(fecha, noa_region, la_rioja_region) %>%
  summarise(empresas = mean(empresas)) %>%
  #mutate(la_rioja = if_else(jurisdiccion == "La Rioja", "3. La Rioja", "1. Resto")) %>%
  ggplot(aes(x = fecha, 
             y = empresas,
             group = la_rioja_region,
             color = la_rioja_region)) +
  geom_line(linewidth = 0.7) +
  scale_color_fundar_multi(name = "Jurisdicción") +
  theme_monitor() +
  theme(axis.text.x = element_text(size = 8)) +
  scale_x_date(date_labels = "%m-%Y", date_breaks = "6 month") +
  labs(
    title   = "Cantidad de empresas por jurisdicción",
    x       = "Fecha",
    y       = "Cantidad de empresas",
    caption = fuente_fundar("Fundar, con base en datos de SRT.")
  ) +
  facet_wrap(~la_rioja_region, scales = "free_y")

ggsave('./outputs/plots/11_empresas_jurisdiccion.png', width = 12, height = 7)
