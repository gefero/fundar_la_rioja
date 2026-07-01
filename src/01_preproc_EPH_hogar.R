library(eph)
library(tidyverse)
library(lubridate)

## Descarga datos
vars <- c("ANO4", "TRIMESTRE","CODUSU", "NRO_HOGAR", ## identificadores
          "REGION", "AGLOMERADO", "PONDERA", # region
          "IV1","IV2", # vivienda
          "IV4", "IV5", "IV6", "IV7", "IV8", "IV9", "IV10", "IV11" , # saneamiento 
          "II1", "II2", # hacinamiento
          "IX_TOT" # Total miembros
          )

periods <- expand_grid(year = 2007:2025, period = 1:4)
tictoc::tic()
for (i in 1:nrow(periods)){
  p <- periods$period[[i]]
  y <- periods$year[[i]]
  
  out <- paste0('./data/raw_data/eph/hogar/', y, "_", p, "_EPH_hogar.rds")
  
  if (!file.exists(out)){
    
    cat("El archivo no existe. Descargando ", out , "\n")
    df <- get_microdata(
      period = p,
      year = y,
      type = "hogar",
      vars = vars
    ) 
    
    df %>% write_rds(out)
  } else {
    cat("El archivo existe...", "\n")
    next
  }
}
tictoc::toc()

# 1. Get a list of all CSV files with their full system paths
files <- list.files(path = "./data/raw_data/eph/hogar/", 
                    pattern = "\\.rds$", 
                    full.names = TRUE)

### Carga archivo raw
df <- files %>% 
  map(read_rds) %>% 
  bind_rows()

## Preprocesamiento
### Agrega etiquetas
df <- df %>%
  organize_labels(type = "hogar")

## Transforma variables clave
df <- df %>%
  mutate(across(REGION:II2, ~as.character(.x))) %>%
  mutate(ANO4 = as.numeric(ANO4),
    TRIMESTRE = unclass(TRIMESTRE)) %>%
  mutate(fecha = paste0(ANO4, "-0", TRIMESTRE))

## Región
df <- df %>%
  mutate(la_rioja_region = case_when(
    AGLOMERADO == "La Rioja" ~ "3. La Rioja",
    AGLOMERADO != "La Rioja" & REGION == "Noroeste" ~ "2. NOA-Resto",
    TRUE ~ "1. Resto país"
  ))

## Indicadores NBI (Necesidades Básicas Insatisfechas)

### NBI_HAC: hacinamiento (más de 3 personas por cuarto)
df <- df %>%
  mutate(
    II1_num = case_when(II1 %in% c("99", "Ns./Nr.") ~ NA_real_, TRUE ~ as.numeric(II1)),
    personas_por_cuarto = IX_TOT / II1_num,
    NBI_HAC = case_when(
      is.na(personas_por_cuarto) ~ NA_real_,
      personas_por_cuarto > 3 ~ 1,
      TRUE ~ 0
    )
  )

### NBI_VIV: vivienda de tipo inconveniente (excluye casa, departamento y rancho)
df <- df %>%
  mutate(NBI_VIV = case_when(
    IV1 %in% c("Casa", "Departamento", "Rancho") ~ 0,
    IV1 %in% c("Pieza de inquilinato", "Pieza en hotel familiar o pensión",
               "Local no construido para habitación", "Casilla",
               "Vivienda móvil", "Otros") ~ 1,
    TRUE ~ NA_real_
  ))

### NBI_SAN: condiciones sanitarias (sin baño, o baño sin desagüe adecuado)
df <- df %>%
  mutate(NBI_SAN = case_when(
    IV9 %in% c("No") ~ 1,
    IV9 %in% c("Sí", "Si") & IV11 %in% c("Sólo a pozo ciego", "A hoyo/excavación en la tierra") ~ 1,
    IV9 %in% c("Sí", "Si") ~ 0,
    TRUE ~ NA_real_
  ))

### NBI_ESC y NBI_SUB requieren datos de individuo (edad, asistencia escolar,
### relación de parentesco y nivel educativo del jefe/a). Ajustar esta ruta si
### 00_preproc_EPH_individuo.R persiste el dataframe procesado en otro lugar.
df_ind <- read_rds('./data/raw_data/eph/individuo_proc.rds')

## Único agregado por hogar a partir de individuo
agg_ind <- df_ind %>%
  group_by(CODUSU, NRO_HOGAR, fecha) %>%
  summarise(
    ocupados         = sum(ESTADO == "Ocupado", na.rm = TRUE),
    hay_nino_sin_esc = any(CH06 >= 6 & CH06 <= 12 & CH10 != "Sí, asiste", na.rm = TRUE),
    tiene_jefe       = any(CH03 == "Jefe/a", na.rm = TRUE),
    CH12_jefe        = first(CH12[CH03 == "Jefe/a"]),
    CH13_jefe        = first(CH13[CH03 == "Jefe/a"]),
    CH14_jefe        = first(CH14[CH03 == "Jefe/a"]),
    .groups = "drop"
  ) %>%
  mutate(
    NBI_ESC = if_else(hay_nino_sin_esc, 1, 0),
    primaria_3er_grado = case_when(
      !tiene_jefe ~ NA_real_,                                       # jefe no identificado -> excluir
      CH12_jefe %in% c("Primario", "EGB") & CH13_jefe == "Sí" ~ 1,
      CH12_jefe %in% c("Primario", "EGB") & CH13_jefe == "No" & as.numeric(CH14_jefe) >= 3 ~ 1,
      CH12_jefe %in% c("Primario", "EGB") & CH13_jefe == "No" & as.numeric(CH14_jefe) < 3 ~ 0,
      CH12_jefe == "Sin instrucción" ~ 0,
      !is.na(CH12_jefe) ~ 1,  # secundario o más implica primario completo
      TRUE ~ NA_real_
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

### Agregados finales: % de hogares con NBI y % de población en hogares con NBI
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

