install.packages(c("maps", "mapdata"))
devtools::install_github("dkahle/ggmap")
install.packages("tidyverse")
install.packages("scatterpie")
install.packages("ggedit")

library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(scatterpie)
library(ggedit)

usa<-map_data("usa")
jp<-map_data("japan")
pops<-data.frame(read.csv("mapping_pops_cpp_expt.csv"))

us_map<-ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group=group), fill=NA, color="black") + 
  coord_fixed(1.3) + geom_point(data = filter(pops, country=="US"), aes(x = longitude, y = latitude), size = 1) + xlim(c(-90, -65)) +
  geom_label(data=filter(pops, country=="US"), aes(x=longitude, y=latitude, label=pop), hjust=0, label.padding=unit(0.1, "lines")) +
  theme_bw() 

japan_map<-ggplot() + geom_polygon(data = jp, aes(x=long, y = lat, group=group), fill=NA, color="black") + 
  coord_fixed(1.3) + geom_point(data = filter(pops, country=="JP", only_2008=="n"), aes(x = longitude, y = latitude), size = 1)  +
  geom_label(data=filter(pops, country=="JP"), aes(x=longitude, y=latitude, label=pop), hjust=0, label.padding=unit(0.1, "lines")) +
  theme_bw() + theme(axis.title.x=element_blank(), axis.title.y=element_blank())

DI_data<-data.frame(read.csv("diapause_incidence_8h_2008_2018.csv"))
DI_data$ND<-1-DI_data$DI
DI_info<-full_join(DI_data, pops)
DI_info<-rename(DI_info, Diapause=DI, Nondiapause=ND)

remove_geom(us_map, "label") + geom_scatterpie(data=filter(DI_info, country=="US"), aes(x=longitude, y=latitude, r=0.5), cols=c("Diapause", "Nondiapause")) + 
  facet_grid(~year) + theme(axis.title.x=element_blank(), axis.title.y=element_blank())

remove_geom(japan_map, "label") + geom_scatterpie(data=filter(DI_info, country=="JP"), aes(x=longitude, y=latitude, r=0.5), cols=c("Diapause", "Nondiapause")) + 
  facet_grid(~year) + theme(axis.title.x=element_blank(), axis.title.y=element_blank())