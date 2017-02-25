
# This is the server logic for a Shiny web application. 	
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com 
#

library(shiny)
library(jsonlite)
library(httr)
library(magrittr)
library(yaml)


config <- yaml.load_file("config.yml")

shinyServer(function(input, output) {
  
  output$scoring <- renderText({
    
    
    # Take a dependency on input$goButton
    if (input$submitButton == 0)
      return("-")
    
    record <- isolate(data.frame(male = input$gender, age = input$age, 
                          currentSmoker = input$smoker,
                          totChol = input$totChol, sysBP = input$sysBP, 
                          glucose = input$glucose) %>% toJSON)
    response <- GET(config$base_url,
                    authenticate(config$usr, config$pwd),
                    query = list(record = record), content_type_json()) %>% 
      content(as = "text") %>% fromJSON %>% .[["outputs"]] %$%
      as.numeric(Predicted_TenYearCHD) %>% round(digits = 4) * 100
    response <- paste(response, "%")
                        
    response
  })
})




