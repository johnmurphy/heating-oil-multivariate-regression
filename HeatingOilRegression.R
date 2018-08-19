# Does the required library exist, if not install it...
if("GGally" %in% rownames(installed.packages()) == FALSE) {install.packages("GGally")}
if("corrplot" %in% rownames(installed.packages()) == FALSE) {install.packages("corrplot")}
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
if("Hmisc" %in% rownames(installed.packages()) == FALSE) {install.packages("Hmisc")}

# Attached Libraries
library(GGally)
library(corrplot)
library(dplyr)
library(Hmisc, quietly=TRUE)

# Set my working directory
setwd("C:/Data/HeatingOil")

# read csv file into training_raw object
training_raw <- read.csv("HeatingOil-T.csv", stringsAsFactors = F)


'******************************************************************************************

                         Data Understanding and Diagnostics

******************************************************************************************'

# Display number rows and columns for the loaded dataset.
d1 <- dim(training_raw)

# take a peak at the first 15 rows..
head(training_raw, n = 15)

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
                 tl.cex=0.85, # Set table font size
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

# read csv file into scoring object
scoring <- read.csv("HeatingOil-S.csv", stringsAsFactors = F)

# predict heating oil usage on unseen data
Heating_Oil_P <- predict(fit, newdata = scoring)
sum(Heating_Oil_P)

# plot fitted/predicted vs. observed/actual
graphics::plot(stats::predict(fit),training$Heating_Oil, col = "blue",
     xlab="fitted",ylab="observed")
graphics::abline(a=0,b=1, col="red", lwd=2) # add slope line through current plot

# Diagnostic Plots
par(mfrow = c(2, 2)) # plot 2 x 2 
plot(fit, col = "blue")

par(mfrow = c(1,1)) # reset par back to normal 1 pot

#dev.off() # run this is the plots get hosed up in RStudio...

# Deeper dive on influential observations using cooks distance
cooksd <- cooks.distance(fit)

plot(cooksd, pch="*", cex=2, main="Influential Obs by Cooks distance")  # plot cook's distance
abline(h = 3*mean(cooksd, na.rm=T), col="red")  # add cutoff line
text(x=1:length(cooksd)+1, y=cooksd, labels=ifelse(cooksd>3*mean(cooksd, na.rm=T),names(cooksd),""), col="red")  # add labels

influential <- as.numeric(names(cooksd)[(cooksd > 3*mean(cooksd, na.rm=T))])  # influential row numbers
influential_obs <- training[influential, ] # influential observations.
count(influential_obs)

# Influential Observations
# added variable plots 
av.Plots(fit)
# Cook's D plot
# identify D values > 4/(n-k-1) 
cutoff <- 4/((nrow(training)-length(fit$coefficients)-2)) 
plot(fit, which=4, cook.levels=cutoff)
# Influence Plot 
influencePlot(fit,	id.method="identify", main="Influence Plot", sub="Circle size is proportial to Cook's Distance" )

# Assessing Outliers
outlierTest(fit) # Bonferonni p-value for most extreme obs
qqPlot(fit, main="QQ Plot") #qq plot for studentized resid 
leveragePlots(fit) # leverage plots

total_predicted <- sum(predict(fit))
total_actual <- sum(training$Heating_Oil)

# Take a look 
ho_output <- data.frame(
           Insulation = training$Insulation, 
           Temperature = training$Temperature,
           Avg_Age = training$Avg_Age,
           Home_Size = training$Home_Size,
           O_Heating_Oil = training$Heating_Oil, # observed heating oil usage
           F_Heating_Oil = predict(fit), # fitted/predicted heating oil usage
           R_Heating_Oil = residuals(fit) # residuals/error between fitted and observed
           ) %>%
     filter(O_Heating_Oil > 260 & F_Heating_Oil < 250)

# maybe there was latent variables that were not observed or measured
# Any home improvements done new argon gas windows, siding with house wrap
# How much time do the owners spend living at the home? Do they travel often maybe they 
# Is it a rental property? If so, has it been vacant? How long?
# Maybe the owners have 'closed off' a few rooms that they do not regualarly use
# e.g Home Size is 6 but really only heat 4 rooms?

head(training)