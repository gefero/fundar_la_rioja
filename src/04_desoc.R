## 04. Tasa de desocupación

library(tidyverse)

df <- read_rds('./data/proc_data_eph.rds')

### Genero paleta de colores 
### Quiz{as generar un archivo}
nombres_aglomerados <- df %>% select(la_rioja_region) %>% distinct()%>% pull()
nombres_aglomerados<-nombres_aglomerados[order(nombres_aglomerados)]
colores <- c("#2166AC4D", "#E8521AFF", "#BBBBBB80")
names(colores)<-nombres_aglomerados

df %>%
  filter(ANO4 >= 2007) %>%
  group_by(fecha, REGION, AGLOMERADO, la_rioja_region) %>%
  summarise(desoc = sum(desocupado*PONDERA),
            pea = sum(pea*PONDERA),
            ) %>%
  mutate(tasa_desoc = desoc/pea*100) %>%
  ggplot() + 
  geom_line(aes(x=fecha, y=tasa_desoc, group=AGLOMERADO, color=la_rioja_region), 
            show.legend = TRUE) +
  scale_color_manual(name="Región", values=colores) +
  labs(x="Año-Trimestre", 
       y="Tasa de desocupación") +
  theme_minimal() +
  theme(axis.text.x = element_text(size=6, angle = 45, hjust = 1))
