# =============================================================================
# SWATCH DE REFERENCIA — paleta regional (FUNDAR_MULTI)
# -----------------------------------------------------------------------------
# Genera un swatch de los 3 colores regionales del monitor, LEYENDO los hex
# desde style/fundar_monitor_theme.R (no los repite acá). Si alguien cambia un
# color en el tema, este script lo refleja solo, sin quedar desincronizado.
#
# Uso: source("clases/materiales/paleta_regional_swatch.R") desde la raíz del
# repo (fundar_larioja.Rproj abierto en RStudio).
# =============================================================================

library(colorspace)
source("style/fundar_monitor_theme.R")

paleta_regional <- c(
  "1. Resto país" = unname(FUNDAR_MULTI["serie_1"]),
  "2. NOA-Resto"  = unname(FUNDAR_MULTI["serie_2"]),
  "3. La Rioja"   = unname(FUNDAR_MULTI["serie_3"])
)

dir.create("outputs/plots", showWarnings = FALSE, recursive = TRUE)

png("outputs/plots/paleta_regional_la_rioja.png",
    width = 900, height = 260, res = 130)
colorspace::swatchplot(
  paleta_regional,
  main = "Paleta regional — style/fundar_monitor_theme.R (FUNDAR_MULTI)"
)
dev.off()

cat("Swatch guardado en outputs/plots/paleta_regional_la_rioja.png\n")
print(paleta_regional)

# Ver la referencia visual completa, con la lógica de énfasis explicada:
# https://claude.ai/code/artifact/36060d34-7a06-4b84-94fd-331a7838f76f
