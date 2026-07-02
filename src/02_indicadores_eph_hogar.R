library(tidyverse)

## Lee los datasets canónicos de hogar e individuo (generados por
## 01_limpieza_eph.R) y calcula los indicadores de NBI (Necesidades Básicas
## Insatisfechas), escribiendo cada uno como CSV en data/inputs_md/.

df <- read_rds("./data/proc_data/eph_hogar.rds")
df_ind <- read_rds("./data/proc_data/eph_individuo.rds")

## Ocupados y chequeo de escolaridad: agregaciones vectorizadas sobre todas las personas
ocupados_esc <- df_ind %>%
  group_by(CODUSU, NRO_HOGAR, fecha) %>%
  summarise(
    ocupados         = sum(ESTADO == "Ocupado", na.rm = TRUE),
    # Match positivo contra las categorías de "no asiste" (en vez de negar
    # "asiste"), con y sin tilde por las dudas de codificación -- issue #3.
    # Excluye a propósito el código "no corresponde" (CH10==0), que la
    # verificación independiente en Python (sobre los códigos numéricos
    # crudos, sin pasar por organize_labels()) mostró que no debe contarse
    # como "no asiste": entre niños de 6-12 años es un caso raro (24 sobre
    # 439.361 registros) y conceptualmente no es lo mismo que "no asiste".
    hay_nino_sin_esc = any(CH06 >= 6 & CH06 <= 12 &
                             CH10 %in% c("Nunca asistió", "Nunca asistio",
                                         "No asiste, pero asistió", "No asiste, pero asistio",
                                         "Ns./Nr.", "Ns/Nr.", "Ns./Nr", "Ns/Nr"),
                           na.rm = TRUE),
    .groups = "drop"
  )

## Educación del jefe/a: filtrar primero (barato, vectorizado), agrupar después
## sobre un dataframe mucho más chico (~1 fila por hogar en vez de todas las personas).
## Evita el patrón lento first(x[condición]) dentro de un summarise() agrupado sobre
## el total de personas.
jefe_educ <- df_ind %>%
  filter(CH03 == "Jefe/a") %>%
  group_by(CODUSU, NRO_HOGAR, fecha) %>%
  summarise(
    CH12_jefe = first(CH12),
    CH13_jefe = first(CH13),
    CH14_jefe = first(CH14),
    .groups = "drop"
  ) %>%
  mutate(
    # CH14 viene vacío ("") por patrón de salto normal (cuando CH13=="Sí" no
    # aplica la pregunta), y en un puñado de casos con texto no numérico. Se
    # reemplaza por NA ANTES de convertir a número, para que as.numeric() nunca
    # reciba un string no numérico y no dispare "NAs introduced by coercion".
    CH14_jefe = if_else(grepl("^[0-9]+$", CH14_jefe), CH14_jefe, NA_character_),
    CH14_num  = as.numeric(CH14_jefe)
  )

agg_ind <- ocupados_esc %>%
  left_join(jefe_educ, by = c("CODUSU", "NRO_HOGAR", "fecha")) %>%
  mutate(
    NBI_ESC = if_else(hay_nino_sin_esc, 1, 0),
    primaria_3er_grado = case_when(
      is.na(CH12_jefe) ~ NA_real_,                                  # jefe no identificado -> excluir
      CH12_jefe %in% c("Primario", "EGB") & CH13_jefe == "Sí" ~ 1,
      CH12_jefe %in% c("Primario", "EGB") & CH13_jefe == "No" & CH14_num >= 3 ~ 1,
      CH12_jefe %in% c("Primario", "EGB") & CH13_jefe == "No" & CH14_num < 3 ~ 0,
      CH12_jefe == "Sin instrucción" ~ 0,
      TRUE ~ 1  # secundario o más implica primario completo
    )
  ) %>%
  select(CODUSU, NRO_HOGAR, fecha, ocupados, NBI_ESC, primaria_3er_grado)

### NBI_ESC, NBI_SUB y NBI_TOT (jefe no identificado -> hogar excluido de SUB y TOT)
df_nbi <- df %>%
  left_join(agg_ind, by = c("CODUSU", "NRO_HOGAR", "fecha")) %>%
  mutate(
    NBI_ESC = if_else(is.na(NBI_ESC), 0, NBI_ESC),  # sin niños 6-12 -> no aplica
    personas_por_ocupado = if_else(ocupados > 0, IX_TOT / ocupados, Inf),
    NBI_SUB = case_when(
      is.na(primaria_3er_grado) ~ NA_real_,
      personas_por_ocupado >= 4 & primaria_3er_grado == 0 ~ 1,
      TRUE ~ 0
    ),
    NBI_TOT = case_when(
      NBI_HAC == 1 | NBI_VIV == 1 | NBI_SAN == 1 | NBI_ESC == 1 | NBI_SUB == 1 ~ 1,
      is.na(NBI_SUB) ~ NA_real_,
      TRUE ~ 0
    )
  )

### 13a. % de hogares con NBI
df_nbi %>%
  filter(!is.na(NBI_TOT)) %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(
    hogares_NBI_TOT = sum(NBI_TOT * PONDERA, na.rm = TRUE),
    hogares_NBI_HAC = sum(NBI_HAC * PONDERA, na.rm = TRUE),
    hogares_NBI_VIV = sum(NBI_VIV * PONDERA, na.rm = TRUE),
    hogares_NBI_SAN = sum(NBI_SAN * PONDERA, na.rm = TRUE),
    hogares_NBI_ESC = sum(NBI_ESC * PONDERA, na.rm = TRUE),
    hogares_NBI_SUB = sum(NBI_SUB * PONDERA, na.rm = TRUE),
    hogares_base    = sum(PONDERA, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pct_hogares_NBI_TOT = hogares_NBI_TOT / hogares_base * 100,
    pct_hogares_NBI_HAC = hogares_NBI_HAC / hogares_base * 100,
    pct_hogares_NBI_VIV = hogares_NBI_VIV / hogares_base * 100,
    pct_hogares_NBI_SAN = hogares_NBI_SAN / hogares_base * 100,
    pct_hogares_NBI_ESC = hogares_NBI_ESC / hogares_base * 100,
    pct_hogares_NBI_SUB = hogares_NBI_SUB / hogares_base * 100
  ) %>%
  write_csv('./data/inputs_md/13a_nbi_hogares.csv')

### 13b. % de población en hogares con NBI
df_nbi %>%
  filter(!is.na(NBI_TOT)) %>%
  mutate(pond_pob = IX_TOT * PONDERA) %>%
  group_by(fecha, la_rioja_region) %>%
  summarise(
    pob_NBI_TOT = sum(NBI_TOT * pond_pob, na.rm = TRUE),
    pob_NBI_HAC = sum(NBI_HAC * pond_pob, na.rm = TRUE),
    pob_NBI_VIV = sum(NBI_VIV * pond_pob, na.rm = TRUE),
    pob_NBI_SAN = sum(NBI_SAN * pond_pob, na.rm = TRUE),
    pob_NBI_ESC = sum(NBI_ESC * pond_pob, na.rm = TRUE),
    pob_NBI_SUB = sum(NBI_SUB * pond_pob, na.rm = TRUE),
    pob_base    = sum(pond_pob, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pct_pob_NBI_TOT = pob_NBI_TOT / pob_base * 100,
    pct_pob_NBI_HAC = pob_NBI_HAC / pob_base * 100,
    pct_pob_NBI_VIV = pob_NBI_VIV / pob_base * 100,
    pct_pob_NBI_SAN = pob_NBI_SAN / pob_base * 100,
    pct_pob_NBI_ESC = pob_NBI_ESC / pob_base * 100,
    pct_pob_NBI_SUB = pob_NBI_SUB / pob_base * 100
  ) %>%
  write_csv('./data/inputs_md/13b_nbi_poblacion.csv')
