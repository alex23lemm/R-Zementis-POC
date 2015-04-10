
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Estimating Your 10-year Risk of Having a Heart Attack"),
  
  hr(),
  fluidRow(
    column(12,
    wellPanel("Note: After pressing the submit button your data will be send to a 
              Zementis instance in the Amazon's EC2 cloud. The deployed logistic 
              regression model will predict the probabilty that you will suffer 
              from a heart disease in 10 years from now. The model was built and trained
              using data from the Framingham Heart Study.")
    )
  ),
  
  fluidRow(
    column(6,
           radioButtons("gender", label = "Your gender", 
                        choices = list("Woman" = 0, "Man" = 1)),
           numericInput("age", label = "Your age", value = 25, min = 15, 
                        max = 100),
            radioButtons("smoker", label = "Do you smoke?",
                         choices = list("No" = 0, "Yes" = 1)),
           numericInput("totChol", label = "Total Cholesterol in your blood", 
                         value  = 230, min = 0, max = 700),
           numericInput("sysBP", label = "Your systolic blood pressure", 
                         value = 120, min = 0, max = 400),
           numericInput("glucose", label = "Your glucose level", value = 85)
    )
    
  )
  
  
  
  
  

 
  
))
