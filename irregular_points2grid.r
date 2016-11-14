# Irregular points to grid

library(raster)
library(sp)

path="O:/Documents/CHRIS_Bristol/Bathymetry_data/Fenty_ALLOWED/2013-2014 Rignot and others bathymetry/2013-2014 Rignot and others bathymetry/"
f<-capture.output(cat(path, "2014_Greenland_Rignot-Weinreibe-Cofaigh_Nash_DiskoBay_100m_UTM84-22N_m.xyz", sep=""))
pts <- read.table(f, header=FALSE, col.names=c("x", "y", "z"))
names(pts)
ncol(pts)
class(pts)

# create a SpatialPointsDataFrame
coordinates(pts) = ~x+y # create a spatialPoints data frame
extentPTS<-extent(pts)

# create an empty raster object
##rast <- raster(ncol = 10, nrow = 10)
##extent(rast) <- extent(pts)
rast <- raster(ext=extentPTS, resolution=250)

# create your output raster
rasOut<-rasterize(pts, rast, pts$z, fun = mean)
image(rasOut)

#write it out
fout=capture.output(cat(path, "rignot_bathym_mean_grid_250m.tif"))
writeRaster(rasOut, fout, format="GTiff")
