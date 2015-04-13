    library(pmml)
    library(caTools)
    library(ROCR)

Read and process data
---------------------

    framingham <- read.csv("./data/framingham.csv")

    dim(framingham)

    ## [1] 4240   16

    sum(complete.cases(framingham))

    ## [1] 3658

    framingham <- framingham[complete.cases(framingham), ]

What is the accuracy of the baseline model?

    tab <- table(framingham$TenYearCHD)
    tab

    ## 
    ##    0    1 
    ## 3101  557

    baseline <- tab[1]/sum(tab)
    baseline

    ##        0 
    ## 0.847731

Split the data into training and test set:

    set.seed(37)

    split <- sample.split(framingham$TenYearCHD, SplitRatio = 0.65)

    fram_train <- framingham[which(split), ]
    fram_test <- framingham[which(!split), ]

Build logistic regression models and apply them on training set
---------------------------------------------------------------

First model
-----------

Build model including all available independent variables:

    fram_log_complete <- glm(TenYearCHD ~ ., family = binomial, data = fram_train)
    summary(fram_log_complete)

    ## 
    ## Call:
    ## glm(formula = TenYearCHD ~ ., family = binomial, data = fram_train)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -1.2876  -0.5948  -0.4272  -0.2804   2.8364  
    ## 
    ## Coefficients:
    ##                   Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)     -8.8183376  0.9097925  -9.693  < 2e-16 ***
    ## male             0.5362276  0.1361121   3.940 8.16e-05 ***
    ## age              0.0662533  0.0083257   7.958 1.75e-15 ***
    ## education       -0.0291042  0.0605386  -0.481  0.63069    
    ## currentSmoker    0.1052663  0.1954671   0.539  0.59021    
    ## cigsPerDay       0.0156468  0.0077279   2.025  0.04290 *  
    ## BPMeds           0.0739897  0.3026413   0.244  0.80686    
    ## prevalentStroke  0.0606532  0.7055752   0.086  0.93150    
    ## prevalentHyp     0.2491220  0.1702946   1.463  0.14350    
    ## diabetes        -0.1113356  0.4053910  -0.275  0.78359    
    ## totChol          0.0033513  0.0013718   2.443  0.01457 *  
    ## sysBP            0.0145090  0.0046546   3.117  0.00183 ** 
    ## diaBP           -0.0076333  0.0077439  -0.986  0.32427    
    ## BMI              0.0110059  0.0152946   0.720  0.47178    
    ## heartRate       -0.0003788  0.0053151  -0.071  0.94319    
    ## glucose          0.0090611  0.0028936   3.131  0.00174 ** 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 2028.7  on 2377  degrees of freedom
    ## Residual deviance: 1789.2  on 2362  degrees of freedom
    ## AIC: 1821.2
    ## 
    ## Number of Fisher Scoring iterations: 5

The following variables are significant: `male`, `age`, `cigsPerDay`,
`totChol`, `sysBP` and `glucose`.

In addition, we observe an AIC of 1821.1524142.

Next, we evaluate the in-sample accuracy.

    predict_train1 <- predict(fram_log_complete, type = "response")
    t1_train <- table(fram_train$TenYearCHD, predict_train1 >= 0.5)
    t1_train

    ##    
    ##     FALSE TRUE
    ##   0  2008    8
    ##   1   333   29

    sum(diag(t1_train))/sum(t1_train)

    ## [1] 0.8566022

### Second model

Next, we build a second model using some of the significant variables
plus those identified as risk factors for corony heart diseases in other
studies.

    fram_log2 <- glm(TenYearCHD ~ male + age + currentSmoker + totChol + sysBP +
                       glucose, family = 'binomial', data = fram_train)
    summary(fram_log2)

    ## 
    ## Call:
    ## glm(formula = TenYearCHD ~ male + age + currentSmoker + totChol + 
    ##     sysBP + glucose, family = "binomial", data = fram_train)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -1.4024  -0.5958  -0.4338  -0.2827   2.7832  
    ## 
    ## Coefficients:
    ##                Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)   -9.367899   0.595642 -15.727  < 2e-16 ***
    ## male           0.602264   0.127889   4.709 2.49e-06 ***
    ## age            0.066759   0.007934   8.415  < 2e-16 ***
    ## currentSmoker  0.383345   0.129120   2.969  0.00299 ** 
    ## totChol        0.003455   0.001362   2.537  0.01119 *  
    ## sysBP          0.015735   0.002643   5.954 2.61e-09 ***
    ## glucose        0.008688   0.002148   4.044 5.26e-05 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 2028.7  on 2377  degrees of freedom
    ## Residual deviance: 1797.2  on 2371  degrees of freedom
    ## AIC: 1811.2
    ## 
    ## Number of Fisher Scoring iterations: 5

All independent variables are significant whereas 4 out of 6 are even
highly statistically significant. All *β* coefficients show a positive
sign.

    predict_train2 <- predict(fram_log2, type = "response")

    t2_train <- table(fram_train$TenYearCHD, predict_train2 >= 0.5)
    t2_train

    ##    
    ##     FALSE TRUE
    ##   0  2002   14
    ##   1   336   26

    sum(diag(t2_train))/sum(t2_train)

    ## [1] 0.8528175

We will only apply the second model on our test set even though the
first one possesses a slightly higher in-sample accuracy and a slightly
higher AIC.

Apply final model on test set
-----------------------------

    predict_test <- predict(fram_log2, type = "response", newdata = fram_test)
    summary(predict_test)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ## 0.01468 0.06564 0.11490 0.14960 0.20420 0.94190

    t1_test <- table(fram_test$TenYearCHD, predict_test >= 0.5)
    t1_test

    ##    
    ##     FALSE TRUE
    ##   0  1077    8
    ##   1   185   10

    acc <- sum(diag(t1_test))/sum(t1_test)
    acc

    ## [1] 0.8492188

The result shows that our logistic regression model (0.8492188) has a
slight edge over the baseline model (0.847731) in terms of overall
accuracy.

Let's have a look at the Receiver Operator Characteristic curve:

    rocr_pred <- prediction(predict_test, fram_test$TenYearCHD)
    rocr_perf <- performance(rocr_pred, "tpr", "fpr")
    plot(rocr_perf, colorize = TRUE, print.cutoffs.at = seq(0, 1, 0.1), 
         text.adj = c(-0.1, 1))

![](build_and_export_model_files/figure-markdown_strict/unnamed-chunk-10-1.png)

What about the AUC?

    rocr_auc <- as.numeric(performance(rocr_pred, "auc")@y.values)
    rocr_auc

    ## [1] 0.7355028

Export PMML file
----------------

    glm_pmml <- pmml(fram_log2, model.name = "CHD_prediction_model")
    xmlFile <- file.path(getwd(),"files/chd_risk_glm.xml")
    saveXML(glm_pmml,xmlFile)
