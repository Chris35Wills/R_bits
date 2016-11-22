# Various R plotting wrappers
#
# Help:
# 	http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/#palettes-color-brewer

library(ggplot2)

#' resample a dataframe
Nth.row <- function(dataframe, n) dataframe[(seq (n, to=nrow(dataframe), by=n)),]

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

#' Takes in a dataframe and plots a scatter coloured by z
#' pnts - a dataframe containing at least 3 cols representing x and y coords and an attribute
#' x_label - label for the x axis
#' y_label - label for the y axis
#' x - name of the x column in the pnts dataframe
#' y - name of the y column in the pnts dataframe
#' z - name of the z column in the pnts dataframe 
#' resample - set to an integer if you want to take every nth point of the input dataframe
#'
#' e.g. colour_scatter(pnts_df, z='quasi_mean')
colour_scatter <- function(pnts_df, x='x', y='y', z='z', x_label='x', y_label="y", resample="", cbar_midpoint=0){
	
	if (class(pnts_df) != "data.frame") {
		print("Trying to convert pnts to a dataframe...")
		pnts_df=as.data.frame()
		print("Dataframe conversion successful")
	}
	
	if (resample != ""){
		cat("Resampling points - plot will use every ", resample, " points\n", sep="")
		pnts_df <- Nth.row(pnts_df, resample)
	}

	# Colorblind friendly palette with grey:
	cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

	ggplot(data=pnts_df, aes_string(x=x, y=y, color=z)) + 
	geom_point() + 
	#scale_color_discrete() +
	#scale_fill_manual(cbPalette) +
	#scale_colour_hue()l=70, c=150)   # discrete
	scale_colour_gradientn(colours=rainbow(4)) +  # continuous
	#scale_colour_gradient2(midpoint=cbar_midpoint, low="red", high="blue") + # colorbar default centres on zero  
	labs(x = x_label, y = y_label)

}

#####################################################
############ FOR GEOSTATISTICAL ANALYSIS ############
#####################################################

#' Plot the experimental variogram
#' vario - the output of variogram() in package gstat
#' sqrt_semivar - if TRUE, takes sqrt of semivariance, giving units equal to those of the original input points
#' Help: https://www.r-bloggers.com/variography-with-gstat-and-ggplot2/
#' Example
#' 	x_label="Lag"
#' 	ggplot.variogram(vario, xlabel=x_label)
ggplot.variogram <- function(vario, xlabel='Distance', ylabel='Semivariance', sqrt_semivar=FALSE) {
 
 
 	if (sqrt_semivar==FALSE){	
 		plt=ggplot(vario,aes(x=dist,y=gamma))
 	} else { 	
 		vario$gamma=sqrt(vario$gamma)
 		plt=ggplot(vario,aes(x=dist,y=gamma))
 		y_label="Square-root of semivariance (sp units of z of the inputs)"
 	}
  
  	plt +
    geom_point() +
    expand_limits(y=0) +
    labs(x = x_label, y = y_label)
}

#http://stats.stackexchange.com/questions/58899/what-does-the-semivariance-tell-me

# Calculate predicted values using a variogram model at positions held by points in the experimental variogram
#' vario 	   	   - output of variogram() (gstat)
#' vario.model.fit - output of fit.variogram() (gstat)
vgm.model.pred.vals<-function(vario, vario.model.fit){
	obs.dist <- vario[,2]
	obs.semivar <- vario[,3]
	
	## get predicted dists and semivariances at same locations as obs from experimental variogram...
	# This was asked as a StackExchange question - see here for the question and answer:
	# http://stats.stackexchange.com/questions/168031/gstat-modelled-semivariogram-values-not-matching-plotted-model-using-the-variog/168866#168866
	#m <-variogramLine(vgm_model_fit, max(obs.dist), min=0.0000000001, dist_vector=observation.dist, n=15)
	pred_dist_semivar <-variogramLine(vario.model.fit, max(obs.dist), min=min(obs.dist), dist_vector=obs.dist)
	
	return(pred_dist_semivar)

}

#' Plot the variogram and the variogram model - alternative to plot(vario, vario.model but not quite right...)
#' vario 	   - output of variogram() (gstat)
#' vario.model - output of fit.variogram() (gstat)
ggplot.variogram.pls.model<-function(vario, vario.model.fit, xlabel='Distance', ylabel='Semivariance'){
	
	predicts=vgm.model.pred.vals(vario, vario.model.fit)
	colnames(predicts)=c("dist", "pred")

	combo<-cbind(vario, predicts)

	ggplot(combo,aes(x=dist,y=gamma, pred=pred)) +
	geom_point(aes(x=dist, y=gamma)) + # the experimental variogram points
	geom_line(aes(x=dist, y=pred)) + # the predicted model
	expand_limits(y=0) +
	labs(x = x_label, y = y_label)

}

###############################################
###############################################
###############################################
###############################################
### more variogram plotting - develop....
#
#library(gstat) 
#library(ggplot2) 
#data(meuse) 
#
#coordinates(meuse) = ~x+y 
#vgIso <- variogram(log(zinc)~x+y, meuse) 
#vgIso$id <- "iso" 
#
#vgAniso <- variogram(log(zinc)~x+y, meuse, alpha=c(0,45,90,135)) 
#vgAniso$id <- "aniso" 
#
#ggplot(vgIso, aes(x = dist, y = gamma, weight = np / (dist ^ 2), 
#		colour = id)) + 
#			geom_smooth() + # just added a smooth line
#			geom_point() 
#
#
#Empirical <- rbind(vgIso, vgAniso) 
#
#ggplot(Empirical, aes(x = dist, y = gamma, weight = np / (dist ^ 2), 
#		colour = id, shape = factor(dir.hor))) + 
#			geom_smooth() + 
#			geom_point() 
#
#ggplot(Empirical, aes(x = dist, y = gamma, weight = np / (dist ^ 2), 
#colour = id)) + geom_smooth() + geom_point() + facet_wrap(~dir.hor) 
