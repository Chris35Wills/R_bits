# REGULARLY GRIDDED XYZ TO RASTER (R) -> rasterFromXYZ

# https://cran.r-project.org/web/packages/raster/raster.pdf

# R's raster paackage provides functionality to create a raster from regulrly gridded points - to summarize the documentation:

# NB/ If using the function and not specifying the raster resolution, it is assumed to be the minimum distance
# between x and y coordinates. Also, if the exact properties of the RasterLayer are known beforehand, it may be preferable to simply create a new
# RasterLayer with the raster function instead, compute cell numbers and assign the values with these
# (see example below).

# Usage:

rasterFromXYZ(xyz, res=c(NA,NA), crs=NA, digits=5)

# Example:
	
## create some regularly gridded point data:

r <- raster(nrow=10, ncol=10, xmn=0, xmx=10, ymn=0, ymx=10, crs=NA) # empty raster
r[] <- runif(ncell(r)) 												# set values of raster between 0 and 1 
r[r<0.5] <- NA 														# set some to NA
xyz <- rasterToPoints(r) 											# create regularly gridded points

## create raster from points

r2 <- rasterFromXYZ(xyz) 

## ...equivalent to computing cell numbers and assigning them with values:

r3 <- raster(nrow=10, ncol=10, xmn=0, xmx=10, ymn=0, ymx=10) 		# empty raster
cells <- cellFromXY(r3, xyz[,1:2]) 									# compute cell numbers
r3[cells] <- xyz[,3] 												# assign values to cells
