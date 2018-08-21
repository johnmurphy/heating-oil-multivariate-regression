# Does the required library exist, if not install it...
if("GGally" %in% rownames(installed.packages()) == FALSE) {install.packages("GGally")}
if("corrplot" %in% rownames(installed.packages()) == FALSE) {install.packages("corrplot")}
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
if("Hmisc" %in% rownames(installed.packages()) == FALSE) {install.packages("Hmisc")}
if("zoo" %in% rownames(installed.package()) == FALSE) {install.packages("zoo")}

# Attached Libraries
library(GGally)
library(corrplot)
library(dplyr)
library(Hmisc, quietly=TRUE)
library(zoo)

# Set my working directory
setwd("C:/Data/HeatingOil")

# read csv file into training_raw object
training_raw <- read.csv("HeatingOil-T.csv", stringsAsFactors = F)


'******************************************************************************************

                         Data Understanding and Diagnostics

******************************************************************************************'

# Display number rows and columns for the loaded dataset.
d1 <- dim(training_raw)

# take a peak at the first and last 15 rows..
head(training_raw, n = 15)
tail(training_raw, n = 10) # Last 15 rows

# what does the object structure look like?
str(training_raw)

# What kinds of objects are in the dataset and what are their data types?
# A couple ways to view it.
sapply(training_raw, class)
sapply(training_raw, typeof)
contents(training_raw)

# Look at summary statistics
summary(training_raw)
describe(training_raw)

# What is the Standard Deviation? 
sapply(training_raw, sd)

# Visualize the data. Look for relationships
# Basic Scatterplot Matrix using pairs
pairs(training_raw, 
      panel = panel.smooth, 
      lwd = 2, 
      pch = 21, 
      bg = "light blue",
      cex = .85)

# Generate correlation matrix with cor() and corrplot()
training_raw  %>%
  cor() %>%
  corrplot.mixed(upper = "ellipse", 
                 tl.cex = 0.85, # Set table font size
                 number.cex = 1.3, # Set number font size
                 order = 'FPC')# order by first principal component.

if("usdm" %in% rownames(installed.packages()) == FALSE) {install.packages("usdm")}
library(usdm) # needed for vif function below.

# Evaluate Collinearity
# conservatively a VIF > 5 can be problematic; however, 
# this is much debate as to the "best" threshold
# Some suggest that VIF between 1 and 5 indicates that 
# there is a moderate correlation, but it is not severe 
# enough to warrant corrective measures
vif(training_raw) # variance inflation factors 

training <- training_raw %>%
            dplyr::select(-Num_Occupants) # Remove Num_Occupants

'******************************************************************************************

                            Build Regression and Evaluate

******************************************************************************************'

# Build a Regression model with Heating_Oil as the response/target variable.
fit <- lm(Heating_Oil ~ ., data=training)

# View summary details
summary(fit)

# plot fitted/predicted vs. observed/actual
graphics::plot(stats::predict(fit),training$Heating_Oil, col = "blue",
     xlab = "fitted",ylab = "observed")
graphics::abline(a = 0,b = 1, col = "red", lwd = 2) # add slope line through current plot

# Diagnostic Plots
par(mfrow = c(2, 2)) # plot 2 x 2 
plot(fit, col = "blue")

par(mfrow = c(1,1)) # reset par back to normal 1 pot

#dev.off() # run this if the plots get hosed up in RStudio...

# Deeper dive on influential observations using cooks distance
cooksd <- cooks.distance(fit)

# Plot the values
plot(cooksd, pch = 1, cex = 1.3, col = "blue", main="Influential Observations by Cooks distance")  # plot cook's distance
abline(h = 3 * mean(cooksd, na.rm = T), col = "red")  # add cutoff line
text(x = 1:length(cooksd) + 1
     , y = cooksd 
     , labels=ifelse(cooksd > 3 * mean(cooksd, na.rm = T)
                     ,names(cooksd),"")
     , col = "red", cex = 0.85, pos = 4, offset = 0.4)  # add labels

# Identify Observations
influential <- as.numeric(names(cooksd)[(cooksd > 3 * mean(cooksd, na.rm = T))])  # influential row numbers
influential_obs <- training[influential, ] # influential observations.
influential_obs$observation <- rownames(influential_obs) # make row name a column
count(influential_obs) # How many are there?

# Lets look at the top 10 values and analyze the data. There are 53 total
# but we will, to begin with, focus on the top 10.
dfTop10 <- as.data.frame(sort(cooks.distance(fit), decreasing = T)[1:10]) 
colnames(dfTop10)[1] <- "Cooks_Value" # rename column name
dfTop10$observation <- rownames(dfTop10) # make row name a column

#sort(lm.influence(fit, do.coef = FALSE)$hat, decreasing = T)[1:10]

# Review outliers and observed features
inner_join(x = dfTop10, y = influential_obs)

'******************************************************************************************

                            Apply Model to Unseen Data

******************************************************************************************'

# predict heating oil usage on unseen data
# read csv file into scoring object
scoring <- read.csv("HeatingOil-S.csv", stringsAsFactors = F)
Heating_Oil_P <- predict(fit, newdata = scoring)

# predicted heating oil amount
sum(Heating_Oil_P)
