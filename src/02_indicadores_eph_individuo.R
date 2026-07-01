library(tidyverse)

## Lee el dataset canónico de individuo (generado por 01_limpieza_eph.R) y
## calcula los indicadores basados en individuo, escribiendo cada uno como
## CSV en data/inputs_md/.

df <- read_rds("./data/proc_data/eph_individuo.rds")

#### 10. Tasa de empleo
df %>%
  filter(ANO4 >= 2007) %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(ocupado = sum(ocupado * PONDERA),
            pob_tot = sum(PONDERA),
            .groups = "drop") %>%
  mutate(tasa_empleo = ocupado / pob_tot * 100) %>%
  write_csv('./data/inputs_md/10_tasa_empleo.csv')

#### 04. Tasa de desocupación
df %>%
  filter(ANO4 >= 2007) %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(desoc = sum(desocupado * PONDERA),
            pea = sum(pea * PONDERA),
            .groups = "drop") %>%
  mutate(tasa_desoc = desoc / pea * 100) %>%
  write_csv('./data/inputs_md/04_tasa_desoc.csv')

#### 09a. Tasa de informalidad (aportes)
df %>%
  filter(ANO4 >= 2007) %>%
  filter(ESTADO == "Ocupado" & CAT_OCUP == "Obrero o empleado") %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(formales = sum(aportes_descuentos * PONDERA),
            asalariados = sum(asalariado_ocupado * PONDERA),
            .groups = "drop") %>%
  mutate(tasa_inf_aportes = 100 - (formales / asalariados * 100)) %>%
  write_csv('./data/inputs_md/09a_tasa_informalidad_aportes.csv')

#### Tasa informalidad b PENDIENTE

#### 12. % mayores de 25 años con nivel superior completo
df %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(mayor_25_superior = sum(mayor_25_superior * PONDERA),
            pob_tot = sum(PONDERA),
            .groups = "drop") %>%
  mutate(porc_mayor_25_superior = mayor_25_superior / pob_tot * 100) %>%
  write_csv('./data/inputs_md/12_mayor_25_superior.csv')
