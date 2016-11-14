# Various R plotting wrappers

library(ggplot2)

#' Takes in values and calculates a historgram with density overlain
#' If you want to do this for a raster, set vals as values(your_raster)
plot_hist_density <- function(vals, binwidth=.5, x_label='Value', y_label="Density"){
	
	dat<-data.frame(elevs=vals)
	ggplot(dat, aes(x = elevs)) + 
	    geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                   	binwidth=binwidth,
                   	colour="black", fill="white") +
    	geom_density(alpha=.2, fill="#0066ff")  +  #Overlay with transparent density plot # hexolor key: http://www.w3schools.com/colors/colors_picker.asp
    	labs(x = x_label, y = y_label)

}