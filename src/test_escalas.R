library(RColorBrewer)

data <- RColorBrewer::brewer.pal.info
data$pal_name <- rownames(data)
rownames(data)<-NULL


hex_brewer <- list()
for (i in 1:nrow(data)){

  hex_brewer[[data$pal_name[i]]] <- brewer.pal(data$maxcolors[i], data$pal_name[i])
}
