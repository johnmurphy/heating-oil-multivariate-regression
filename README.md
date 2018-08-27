### Background/Objective:
The Igloo Heating Oil company is a fictitious US based heating oil distributor. Their sales are seasonal where much of their demand takes place from January to February. The ability for the leadership teams to plan and make informed decisions relating to the overall demand, during this time, can be the difference in achieving, or not achieving, the organization’s yearly sales objectives. Understanding demand could also improve the decision making process relating to the following types of questions:

1.	How much oil should be pre-ordered, from the manufacturer, to ensure that supply meets demand, that customer satisfaction is exceeded, and costs/expenses are properly set and managed?
1.	Will there be enough on-site storage capable of meeting future demand? Is there too much? Storage Tanks, Temporary Hold Tanks, Trucks, etc.
1.	Is there enough staff to meet peek demand? Are there enough truck drivers, call center representatives, or technicians? Is there a need to on-board temporary staff?

The leadership teams are interested in understanding the estimated total amount of heating oil demand for the upcoming January to February period. A regression model will be developed to predict the total heating oil purchased using a training data set with the following variables:

1. __Insulation__: Home density rating 1 to 10 with 10 being the highest rating
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
> # What kinds of objects are in the data set and what are their data types? Are there missing values?
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

#### Exploratory Visualization
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
Conservatively a VIF > 5 can be problematic; however, there is much debate as to the "best" threshold. Some suggest that VIF between 1 and 5 indicates that there is a moderate correlation, but it is not severe enough to warrant corrective measures. I do not rely 100% on this measure, but use it as an additional piece information to help me better understand the data and its relationships.

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

Adjusted R-squared (I prefer using Adjusted R-squared) of 0.82 indicates that roughly 82% of the heating oil usage (behavior) can be explained by the model’s independent variables (Insulation, Temperature, Average Age, and Home Size). 

#### Observed (Predicted) vs. Fitted (Actual)
There is something interesting happening along the x-axis (fitted) roughly between points 175 and 250. This definitely highlights a potential issue, as I would like to see points closer to the fitted line. Further analysis is required.

![ObservedFittedPlot](/images/ObservedFittedPlot.png)

#### Diagnostic Plots
How well does the model represent data?

Additional diagnostics. Analyze the residuals. 

The Residuals vs Fitted plot appears to be randomly scattered; However, the points (e.g. 782) in the middle appear to be outliers. Do further analysis to try and identify the cause of the outliers. 

The Normal Q-Q plot looks great until the line sharply breaks at -2 and 2. Further investigate outliers.

The Scale-Location plot is not spread equally. Investigate further (e.g. 782)

Rediduals vs Leverage plot does not have any values outside of the Cook's distance

![DiagnosticPlot](/images/DiagnosticPlots.png)


Deeper look at Cook's distance.
An observation with a Cook's distance larger than three times the mean of Cook's distance might be an outlier. There are 53 identified outliers.

![CooksDistance](/images/CooksDistanceInfluentialObs.png)

Take a look at the 10 top and analyze

````
> inner_join(x = dfTop10, y = influential_obs)
Joining, by = "observation"
   Cooks_Value observation Insulation Temperature Heating_Oil Avg_Age Home_Size
1   0.06472472         240          9          53         290    16.5         8
2   0.05822468        1011          3          86         118    71.0         4
3   0.05510753         123         10          53         290    19.5         8
4   0.05497990         782          7          55         289    16.1         6
5   0.04836170         145          3          74         118    68.1         2
6   0.04752840         689          8          42         277    17.8         8
7   0.04724977         327          8          57         289    19.7         8
8   0.04713504         208          9          39         277    17.5         8
9   0.04324848         790         10          39         276    17.9         8
10  0.04305109        1117         10          60         289    23.2         7
> 
````
#### Some points of interest:
Observation 240 has a high Heating_Oil and a low Avg_Age.  Maybe there is newborn or young child in the house with parents worried about them being cold? Maybe the house is insulated in the attic, but the windows and siding are old and not properly insulated? Or the data captured is not accurate?

Observation 1011 has a very high Temperature that is greater than 3x the standard deviation. It has a low Heating_Oil value with a high Avg_Age. Is it possible this Temperature is incorrect? Thinking about the domain, heating oil is typically used in regions that have longer winter season with lower temperatures.  Observation 145 appears to potentially have the same issue.

Overall, the remaining observations appear to have general pattern between Heating_Oil and Avg_Age. 
#### Next Steps:
Follow up with the business leads to gain a better understanding the analytical findings. Seek feedback and iterate. They might have some additional knowledge that can help improve the model but might not have fully recognized it without being presented with your outcomes.  It takes a team, include them throughout the process.

#### Questions to think about?
* Maybe there are latent variables that were not observed or measured?
* Any home improvements? New argon gas windows, siding with house wrap?
* How much time do the owners spend living at the home? Do they travel often and live in the home one week a month? Is it a rental property? If so, has it been vacant? How long?
* Maybe the owners have 'closed off' a few rooms that they do not regularly use? If so, does home size need to be redefined?
* Is the insulation rating for attic insulation?
* How old is the house?
* Are there any additional features that could be used to augment the data and improve the model and residuals?
