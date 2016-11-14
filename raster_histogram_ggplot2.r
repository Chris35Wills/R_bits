# Help: 
# http://ggplot2.org/book/qplot.pdf
# http://www.cookbook-r.com/Graphs/Plotting_distributions_(ggplot2)/
# http://stackoverflow.com/questions/14668096/how-to-plot-a-raster-file-as-a-histogram-using-ggplot2
 
library(raster)
librar(ggplot2)
library(gridExtra) # < enables plotting on a grid

# Raster data
ABSdiff_R=raster("./absolute_diffs.tif")

##########################qplot()
#
# Simple hist/density plots 
plot1 <- qplot(values(ABSdiff_R), geom = "histogram") # plot 1
plot2 <- qplot(values(ABSdiff_R), geom = "density")   # plot 2
grid.arrange(plot1, plot2, ncol=2)

##########################ggplot()
#
# Plot data from hist function as bar plot (instead of using ggplots hist function directly...)
f <- hist(ABSdiff_R, breaks=30)
ras_hist_data <- data.frame(counts= f$counts,breaks = f$mids)
qplot(ras_hist_data$breaks, ras_hist_data$counts, geom = "bar")

ggplot(ras_hist_data, aes(x = breaks, y = counts)) + geom_bar(stat = "identity",fill='blue',alpha = 0.8)

# More complex hist/density overlay
f <- hist(ABSdiff_R, breaks=30)
#dat <- data.frame(counts= f$counts,breaks = f$mids)
dat<-data.frame(elevs=values(ABSdiff_R))

#histogram
ggplot(dat, aes(x=elevs)) +
    geom_histogram(binwidth=.5, colour="black", fill="white")

#density
ggplot(dat, aes(x=elevs)) + geom_density()

#histogram + density
ggplot(dat, aes(x = elevs)) + 
    geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                   binwidth=.5,
                   colour="black", fill="white") +
    geom_density(alpha=.2, fill="#0066cc") # Overlay with transparent density plot # hexolor ke: http://www.w3schools.com/colors/colors_picker.asp
