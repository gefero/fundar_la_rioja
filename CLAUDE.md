# Fundar-La Rioja

## Introducción
- Este es un repositorio para generar información para el Gobierno de la Rioja.
- El objetivo es generar código que permita reproducir una serie de indicadores

## Indicadores
| Indicadores seleccionados                                                                        | TOPICO                                               |
|--------------------------------------------------------------------------------------------------|------------------------------------------------------|
| Tasa de pobreza multidimensional                                                                 | Desarrollo -  Pobreza                                |
| PIB provincial                                                                                   | Macroeconomía - Crecimiento                          |
| Salarios en el sector formal (público y privado)                                                 | Trabajo e ingresos - Salarios e ingresos             |
| Tasa de desempleo (% de la PEA)                                                                  | Trabajo e ingresos - Informalidad y Desempleo        |
| Puestos de trabajo asalariados formales privados totales                                         | Trabajo e ingresos - Salarios e ingresos             |
| Cantidad de empleados públicos Cada 1.000 Hab                                                    | Trabajo e ingresos - Salarios e ingresos             |
| Cantidad de empresas                                                                             | Macroeconomía - Crecimiento                          |
| % del PIB que es industrial                                                                      | Macroeconomía - Crecimiento                          |
| Tasa de informalidad (% de los asalariados)                                                      | Trabajo e ingresos - Informalidad y Desempleo        |
| Tasa de empleo (ocupados cada 100 habitantes)                                                    | Trabajo e ingresos - Trabajo y participación laboral |
| Exportaciones                                                                                    | Macroeconomía - Crecimiento                          |
| % de la población +25 con estudios superiores completos                                          | Desarrollo - Educación                               |
| Trayectoria escolar                                                                              | Desarrollo - Educación                               |
| Resultado fiscal (ingreso total - gasto total)                                                   | Macroeconomía - Crecimiento                          |
| Recursos propios sobre recursos totales (incluyendo coparticipación y transferencias nacionales) | Macroeconomía - Crecimiento                          |

## Etapas del proyecto
- Etapa 1. Coordinación inicial y definición de indicadores: Esta etapa tiene como propósito articular el trabajo del Componente 3 con los demás equipos del proyecto. Se propone realizar al menos una reunión de alineación con los equipos de los Componentes 1 y 2 para relevar el listado preliminar de indicadores y su naturaleza (evolución temporal, comparación territorial, distribución, proporción, etc.).
- Etapa 2. Diseño de maquetas: En función de los indicadores definidos en la etapa anterior, se definirá para cada uno el tipo de gráfico más adecuado, la paleta de colores a utilizar y la jerarquía visual de la información. El código se desarrolla en R usando ggplot2 como base, con incorporación de plotly cuando se requieran versiones interactivas para uso web. 
- Etapa 3. Diseño de materiales para talleres de visualización de datos y diseño de maquetas de visualizaciones  

## Tareas a realizar
- Diseñar un pipeline replicable de procesamiento de los siguientes indicadores:
      - Tasa de desempleo (% de la PEA)
      - Tasa de empleo (ocupados cada 100 habitantes)
      - Tasa de informalidad (% de los asalariados)
      - % de la población +25 con estudios superiores completos  
- Desarrollar el código para el pipeline
