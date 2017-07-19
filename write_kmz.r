#' Create a GoogleEarth compatable layer from a raster

library(raster)

# Open DEM - in polar stereographic
bedF="/scratch/glacio1/cw14910/Morlighem_bed_2017/outputs/v1.5_may_23rd/bedmachine_ibcao_gebco_combo.tif"
bed=raster(bedF)

# Crop to AOI
xmin=-440180
xmax=91310
ymin=-2388111
ymax=-1826017
ext=c(xmin,xmax,ymin,ymax)
bed_crop=crop(bed, ext)
#image(bed_crop)

# Reproject
wgs84="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
bed_crop_wgs84 <- projectRaster(bed_crop, crs = wgs84, method='ngb')
#image(bed_crop_wgs84)

# Write the GoogleEarth file
ofile="/scratch/glacio1/cw14910/Morlighem_bed_2017/outputs/v1.5_may_23rd/test.kmz"
KML(bed_crop_wgs84, file=ofile, col=terrain.colors(12), overwrite=TRUE, maxpixels=ncell(bed_crop_wgs84))