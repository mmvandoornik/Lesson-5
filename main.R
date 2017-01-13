## In this exercise two landsat images are used:
## A Landsat 5 image obtained at April 8th, 1990
## A Landsat 8 image obtained at April 19th, 2014

library("raster")
library("rgdal")

#untar the files
untar('data/LT51980241990098-SC20150107121947.tar.gz', exdir="data")
untar('data/LC81970242014109-SC20141230042441.tar.gz', exdir="data")

#call functions from separate script
source("R/functions.R")

#list the files and make RasterStack
landsat5 <- stack(list.files('data', pattern=glob2rx('LT51980241990098KIS00*.tif'), full.names=T))
landsat8 <- stack(list.files('data', pattern=glob2rx('LC81970242014109LGN00*.tif'), full.names=T))

#create a common extent
landsat5 <- crop(landsat5, landsat8)
landsat8 <- crop(landsat8, landsat5)

#put the cloude mask layers in separate variables and set values of 0 to NA
fmask_l5 <- landsat5[[1]]
landsat5 <- dropLayer(landsat5, 1)
fmask_l5[fmask_l5 == 0] <- NA

fmask_l8 <- landsat8[[1]]
landsat8 <- dropLayer(landsat8, 1)
fmask_l8[fmask_l8 == 0] <- NA

#Value replacement
landsat5 <- overlay(x = landsat5, y = fmask_l5, fun = cloud2NA)
landsat8 <- overlay(x = landsat8, y = fmask_l8, fun = cloud2NA)

#calculate NDVI
ndvi_landsat5 <- overlay(x=landsat5[[5]], y=landsat5[[6]], fun=ndviFunc)
ndvi_landsat8 <- overlay(x=landsat8[[4]], y=landsat8[[5]], fun=ndviFunc)

#plot the NDVI maps at both dates
plot(ndvi_landsat5, main="NDVI at April 8th, 1990")
plot(ndvi_landsat8, main="NDVI at April 19th, 2014")

#calculate the difference
ndvi <- brick(ndvi_landsat5, ndvi_landsat8)
ndvi_difference <- calc(x=ndvi, fun=difference)

#plot the result
plot(ndvi_difference, main="NDVI difference between 2014 and 1990")

#visualize the result in Google Earth
ndvi_dif_latlon <- projectRaster(ndvi_difference, crs='+proj=longlat')
KML(x=ndvi_dif_latlon, filename='data/NDVI_difference.kml', overwrite=T)
