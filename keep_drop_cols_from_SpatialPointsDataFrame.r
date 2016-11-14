# Keep and drop columns from SpatialPointsDataFrame
#
# Assuming 'data' is a SpatialPointsDataFrame with columns call 'thick' and 'category'...
# Stackoverflow: http://gis.stackexchange.com/questions/109652/how-to-remove-columns-in-a-spatial-polygon-data-frame-in-r

drops <- c("thick_diff") 	            # list of col names to drop
xyz <- data[,!(names(data) %in% drops)] # xyz will only have the category column remaining - xyz@coords etc. still available

keep <- c("thick_diff") 			  # list of col names to keep
xyz <- data[,(names(data) %in% keep)] # xyz will only have the category column remaining - xyz@coords etc. still available
