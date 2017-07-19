#### PREAMBLE ####
##
##
##
##
#### LOAD PACKAGES ####

library('gstat')
library('raster')
library('spacetime')
library('parallel')
rasterOptions(tmpdir='/home/sc13413/temp/')

#### Set up directories

var_file <- '/home/sc13413/cs2_grounding_lines/outputs/st_variograms/test2/st_variogram_sum_metric.rds'
data_file <- '/home/sc13413/cs2_grounding_lines/outputs/st_variograms/test2/STIDF_all_cs2_data.rds'
output_directory <- '/home/sc13413/cs2_grounding_lines/outputs/kriged_surfaces/'
polarxy <- CRS("+proj=stere +lat_0=-90 +lat_ts=-71 +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

#### load data & models

var <- readRDS(var_file)
data <- readRDS(data_file)

#### Set up the prediction grid

# read in raster of trend surface
ras <- raster('/home/sc13413/cs2_grounding_lines/outputs/2011_2012_elevation_krg.tif')

# Just for testing purposes
low_res <- ras
res(low_res) <- 1000.0
ras <- resample(ras, low_res)

# get point co-ordinates
pred_points <- as.data.frame(ras, xy=TRUE, na.rm=TRUE)[,1:2]
coordinates(pred_points) <- ~x+y
proj4string(pred_points) <- polarxy

# now get the time steps for whcih to make predictions
time_seq <- seq(from = as.POSIXct("2010-09-01"), to = as.POSIXct("2016-09-01"), by = "6 months")

prediction_grid.ST <- STF(pred_points, time_seq)

# post <- 250.0
# xy_locations <- data@sp

# min_x <- min(floor(xy_locations@coords[,1]/post))*post
# min_y <- min(floor(xy_locations@coords[,2]/post))*post
# max_x <- max(ceiling(xy_locations@coords[,1]/post))*post
# max_y <- max(ceiling(xy_locations@coords[,2]/post))*post

# x_len<-(max_x - min_x)/post
# y_len<-(max_y - min_y)/post

# r<-raster(extent(min_x, max_x, min_y, max_y),
#           ncols=x_len, 
#           nrows=y_len,
#           crs=CRS(polarxy))

#### Run the spatio-temporal 

#### For parallel processing - set up the number of cores
nclus = detectCores()-2 # use less than the full number to be nice to other people
clus <- c(rep("localhost", nclus))

#### set up the clusters with the libraries needed
cl <- makeCluster(clus, type = "SOCK")
clusterEvalQ(cl, library(gstat))
clusterExport(cl, list("data", "var"))

#### Split the prediction grid up over the cores
splt = sample(1:nclus, nrow(prediction_grid.ST), replace = TRUE) # Assign each spatial point an index
newdlst = lapply(as.list(1:nclus), function(w) prediction_grid.ST[splt == w,]) # cut the data in space for the clusters (time remains the same)

system.time(out.clus <-do.call("rbind", parLapply(cl, newdlst, function(lst) krigeST(resid~1, data=data, modelList=var, newdata= lst, nmax=100, progress=TRUE))))

stopCluster(cl)

### now turn the STFDF into a raster
raster_list <- list()

for(i in 1:length(time_seq)){
	raster_list[[i]] <- rasterize(out.clus[,i], ras, field=out.clus[,i]$var1.pred)
}

### Create rasterbricks of both the residuals and elevations from both timesteps
residual_brick <- brick(raster_list)
elevation_brick <- residual_brick+ras

#### save output
writeRaster(residual_brick, paste(output_directory, '2010_2016_residual_surface_6month.tif', sep=''), 
	format='GTiff')

writeRaster(elevation_brick, paste(output_directory, '2010_2016_elevation_surface_6month.tif', sep=''), 
	format='GTiff')

print('FINISHED SPATIO-TEMPORAL KRIGING OF DATA')