#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(sf)
library(shinythemes)
library(ggsci)


# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("slate"),
                  
                  tags$head(
                      # Note the wrapping of the string in HTML()
                      tags$style(HTML("
                          body {
                            max-width: 960px;
                            margin: auto;
                          }"))
                  ),

    # Application title
    titlePanel("Two Datasets on Far-Right Crimes in Germany"),
    uiOutput("author"),
    uiOutput("map1_info"),

    # Sidebar with a slider input for number of bins

        # Leaflet map 
        leafletOutput("map", width=900, height=600), # for custom CSS 100%
    
    uiOutput("info"),
    uiOutput("map2_info"),
    leafletOutput("map_county", width=900, height=600), # for custom CSS 100%
    uiOutput("imprint"),
    
))
