## 12.% de < 25 on NED alto

library(tidyverse)

### Genero paleta de colores
nombres_aglomerados <- df %>% select(la_rioja_region) %>% distinct()%>% pull()
nombres_aglomerados<-nombres_aglomerados[order(nombres_aglomerados)]
colores <- c("#2166AC4D", "#E8521AFF", "#BBBBBB80")
names(colores)<-nombres_aglomerados


df %>%
  group_by(fecha, REGION, AGLOMERADO, la_rioja_region) %>%
  summarise(value = mean(mayor_25_superior)) %>%
  ggplot() + 
  geom_line(aes(x=fecha, y=value, group=AGLOMERADO, color=la_rioja_region), 
            show.legend = TRUE) +
  scale_color_manual(name="Región", values=colores) +
  labs(x="Año-Trimestre", 
       y="% de personas mayores de 25 años con estudios superiores completos") +
  theme_minimal() +
  theme(axis.text.x = element_text(size=6, angle = 45, hjust = 1))

