### Background/Objective:
The Igloo Heating Oil company is a fictitious US based heating oil distributor. Their sales are seasonal where much of their demand takes place from January to February. As a distributor of heating oil, the ability for the leadership teams to plan and make informed decisions relating to the overall demand, during this time, can be the difference in achieving, or not achieving, the organization’s yearly sales objectives.

The leadership teams are interested in understanding the estimated total amount of heating oil demand for the upcoming January to February period. A regression model will be developed to predict the total heating oil purchased using a training data set with the following variables:

1. __Insulation__: Density rating 1 to 10 with 10 being the highest rating
1. __Temperature__: Average outdoor ambient temperature (Fahrenheit) during January and February
1. __Num_Occupants__: Total number of people living in the home
1. __Avg_Age__: Average age of the people living in the home.
1. __Home_Size__: Rating on a scale of one to eight, of the home’s overall size.
1. __Heating Oil__: Total number of units of heating oil purchased by the owner of each home.

### Thought Process:
Some key steps and actions performed during the data understanding stage of the model building process
````
> # Display number rows and columns for the loaded dataset. 
> dim(training_raw)
[1] 1218    6
````

````
> # take a peak at the first 15 rows. What does the data look like?
> head(training_raw, n = 15)
   Insulation Temperature Heating_Oil Num_Occupants Avg_Age Home_Size
1           6          74         132             4    23.8         4
2          10          43         263             4    56.7         4
3           3          81         145             2    28.0         6
4           9          50         196             4    45.1         3
5           2          80         131             5    20.8         2
6           5          76         129             3    21.5         3
7           5          72         131             4    23.5         3
8           6          88         161             2    38.2         6
9           5          77         184             3    42.5         3
10         10          42         225             3    51.1         1
11          6          90         178             2    42.1         2
12          3          83         121             1    19.8         2
13         10          43         186             5    45.1         6
14          8          59         206             2    50.1         8
15          4          86         179             5    41.4         6
>
````

````
> # What does the object structure look like?
> str(training_raw)
'data.frame':	1218 obs. of  6 variables:
 $ Insulation   : int  6 10 3 9 2 5 5 6 5 10 ...
 $ Temperature  : int  74 43 81 50 80 76 72 88 77 42 ...
 $ Heating_Oil  : int  132 263 145 196 131 129 131 161 184 225 ...
 $ Num_Occupants: int  4 4 2 4 5 3 4 2 3 3 ...
 $ Avg_Age      : num  23.8 56.7 28 45.1 20.8 21.5 23.5 38.2 42.5 51.1 ...
 $ Home_Size    : int  4 4 6 3 2 3 3 6 3 1 ...
````

````
> # What kinds of objects are in the data set and what are their data types?
 > contents(training_raw)
 Data frame:training_raw	1218 observations and 6 variables    Maximum # NAs:0
 
               Storage
 Insulation    integer
 Temperature   integer
 Heating_Oil   integer
 Num_Occupants integer
 Avg_Age        double
 Home_Size     integer
````

````
> # Look at and get familiar with the summary statistics
 > summary(training_raw)
    Insulation      Temperature     Heating_Oil    Num_Occupants       Avg_Age        Home_Size    
  Min.   : 2.000   Min.   :38.00   Min.   :114.0   Min.   : 1.000   Min.   :15.10   Min.   :1.000  
  1st Qu.: 4.000   1st Qu.:49.00   1st Qu.:148.2   1st Qu.: 2.000   1st Qu.:29.70   1st Qu.:3.000  
  Median : 6.000   Median :60.00   Median :185.0   Median : 3.000   Median :42.90   Median :5.000  
  Mean   : 6.214   Mean   :65.08   Mean   :197.4   Mean   : 3.113   Mean   :42.71   Mean   :4.649  
  3rd Qu.: 9.000   3rd Qu.:81.00   3rd Qu.:253.0   3rd Qu.: 4.000   3rd Qu.:55.60   3rd Qu.:7.000  
  Max.   :10.000   Max.   :90.00   Max.   :301.0   Max.   :10.000   Max.   :72.20   Max.   :8.000  
````

````
> # What is the Standard Deviation? What does the spread look like? 
> sapply(training_raw, sd)
   Insulation   Temperature   Heating_Oil Num_Occupants       Avg_Age     Home_Size 
     2.768094     16.932425     56.248267      1.690605     15.051137      2.321226 
> 
````

#### Explanatory Visualization
Visualize the relationships between the independent variables/features. Note that the Num_Occupants essentially appears to have no linear relationship and Home_Size appears to have a slight relationship while the others have meaningful visual relationships.

![Heating Oil Scatter Plots](/images/HeatingOilScatterPlots.png)

This visual analysis is further supported by reviewing the correlation matrix.
![Heating Oil Correlation Matrix](/images/HeatingOilCorrMatrix.png)

#### Some points of interest:
1. Num_Occupants has no correlation between the target variable (Heating_Oil) or any the other independent variables.
1. Home_Size could have some positive correlation (0.4 -> 0.6) with Heating oil but is not correlated with the other independent variables.
1. Heating_Oil and Avg_Age have a very strong positive correlation (0.8 -> 1.0)
1. The remaining variables either have a strong negative or positive correlation (-0.8 <- -0.6 or 0.6 -> 0.8)

Although the independent variables are correlated to Heating_Oil, multicollinearity does exist between the independent variables and if severe can affect the precision of the estimate coefficients and potentially make the p-values untrustworthy. The goal is predictive accuracy but I am interested in the serverity of the correlations and want to analyze how these variables impact each other.

#### Assess Multicollinearity with Variance Inflation Factors (VIF)
````
vif(training_raw)
      Variables      VIF
1    Insulation 3.019653
2   Temperature 3.455863
3   Heating_Oil 5.534132
4 Num_Occupants 1.003545
5       Avg_Age 3.574649
6     Home_Size 1.198744
>
````

#### VIF	Status of predictors
* VIF = 1	Not correlated
* 1 < VIF < 5	Moderately correlated
* VIF > 5 to 10	Highly correlated

Note:
Conservatively a VIF > 5 can be problematic; however, there is much debate as to the "best" threshold. Some suggest that VIF between 1 and 5 indicates that there is a moderate correlation, but it is not severe enough to warrant corrective measures. I do not rely 100% on this measure, but use it as a piece of diagnotics information to help me better understand the data and its relationships.

````
> # Build a Regression model with Heating_Oil as the response/target variable.
> fit <- lm(Heating_Oil ~ ., data=training)
> 
> # View summary details
> summary(fit)

Call:
lm(formula = Heating_Oil ~ ., data = training)

Residuals:
     Min       1Q   Median       3Q      Max 
-104.149  -11.963    0.457   11.623  128.310 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 134.51110    7.58865  17.725  < 2e-16 ***
Insulation    3.32304    0.42032   7.906 5.94e-15 ***
Temperature  -0.86922    0.07112 -12.222  < 2e-16 ***
Avg_Age       1.96801    0.06513  30.217  < 2e-16 ***
Home_Size     3.17325    0.31079  10.210  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


Residual standard error: 23.95 on 1213 degrees of freedom
Multiple R-squared:  0.8192,	Adjusted R-squared:  0.8186 
F-statistic:  1374 on 4 and 1213 DF,  p-value: < 2.2e-16

````

#### Coefficient Interpretation:
1. The coefficient for insulation indicates that for every additional rating in insulation you can expect heating oil usage to increase by an average of 3.32 units with a +/- of 0.42 (Std. Error). P-value is less than .05 indicating that the variable is significant.

2. With each degree increase in temperature you can expect heating oil to decrease by an average of -0.88 units. 
3. With each increase in average age people living in the home you can expect heating oil usage to increase by 1.96 units.
4. With each increase in home size rating you can expect heating oil usage to increase by 3.17 units.

Adjusted R-squared (I prefer using Adjusted R-squared) of 0.82 indicates that roughly 82% of the heating oil usage (behavior) can be explained by the model’s independent variables (Insulation, Temperature, Average Age, and Home Size). Overall a decent goodness of fit, but there is potentially room to improve.

#### Observed (Predicted) vs. Fitted (Actual)
![ObservedFittedPlot](/images/ObservedFittedPlot.png)



#### Diagnostic Plots
![DiagnosticPlot](/images/DiagnosticPlots.png)

