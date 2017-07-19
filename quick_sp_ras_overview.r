library(raster)    # grid stuff
library(sp)        # vector stuff 
library(rasterVis) # fancy raster plotting

# HELP: http://www.maths.lancs.ac.uk/~rowlings/Teaching/UseR2012/cheatsheet.html
# Raster docs: https://cran.r-project.org/web/packages/raster/raster.pdf
# Raster functions (how to write them): https://cran.r-project.org/web/packages/raster/vignettes/functions.pdf
# Vector docs: ftp://cran.r-project.org/pub/R/web/packages/sp/sp.pdf

# Reads in a raster
	#rasF='/home/rasters/mikes_raster.tif'
	ras=raster(rasF)
	# use ras@ to acces various elements of the raster object e.g. ras@extent

	#crs(pnts)<-"+proj=stere +lat_0=90 +lat_ts=71 +lon_0=-39 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs$"
	cellStats(ras, stat=min)

# Reads in points
	pntsF='/home/pnts/mikes_pnts.csv' # csv with a header like: x,y,z
		
	pnts=read.csv(pntsF, header=TRUE) # < csv with header
	
	#pnts=read.table(pntsF, header=FALSE) # < tab/space delimited with no header
	#colnames(pnts)=c('x','y', 'z1', 'z2', 'z3') # if you need to manually define the header

	coordinates(pnts) = ~x+y # x and y must be the header names in the dataframe (i.e. if (x_spec, y_spec) then use ~x_spec+y_spec)
	crs(pnts)<-"+proj=stere +lat_0=90 +lat_ts=71 +lon_0=-39 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs$"
	
	#class(pnts)
	#typeof(pnts)
	
	# as.data.frame(pnts) # to turn points back to dataframe

# Check raser and pnt coordinate systems match
	compareCRS(ras, pnts) # returns TRUE if match
	#compareRaster(ras1, ras2) # comapres extent etc

# Reproject/. tranfrom
	# raster
	#points

# Extract
	pnts$means=extract(ras, pnts)

# write out your points
	ofile='/scratch/output.csv'
	write.csv(pnts, ofile, header=TRUE, row.names=FALSE)





