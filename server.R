
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(jsonlite)
library(RCurl)
library(magrittr)
library(yaml)


config <- yaml.load_file("config.yml")

shinyServer(function(input, output) {
  
  output$scoring <- renderText({
    
    scoring <- "-"
    
    if(input$submitButton > 0){
      scoring <- isolate(data.frame(male = input$gender, age = input$age, currentSmoker = input$smoker,
                                      totChol = input$totChol, sysBP = input$sysBP, 
                                      glucose = input$glucose) %>% 
                             toJSON %>%
                             paste0(config$base_url, "?record=", .) %>% 
                           gsub('\"', "%22", .) %>%
                           getURL(., ssl.verifypeer = FALSE, 
                                    userpwd = paste0(config$usr, ":", config$pwd)) %>%
                           fromJSON %$% outputs %>% as.numeric) 
    }
    scoring 
  })
})




