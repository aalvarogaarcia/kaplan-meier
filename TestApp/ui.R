library(KMsurv)
library(survival)
library(shiny)
library(ggplot2)
library(plyr)

shinyUI(
  navbarPage("Survival Analysis",
             
             #First window 
             tabPanel( "Kaplan-Meier Survival Graph (.xlsx)",
                       
                       #Layout
                       sidebarLayout(
                         
                         #First panel
                         sidebarPanel(
                           h3("Survivial Graph"),
                           
                           fileInput("file", "Choose Excel File", 
                                      accept = c(".xlsx")),
                            
                           uiOutput("sheet_select"),
      
                           #SelectInput gives you the option to choose the variable of time
                           uiOutput('time_select'),
      
      
                           #SelectInput gives you the option to select the delta variable
                           uiOutput('delta_select'),
      
                           actionButton("charge", "Load for delta"),
      
                           #SelectInput gives you the option to choose the variable you want to observe in a dropdown list
                           uiOutput('sur_var'),
                           
                           uiOutput('reload'),
      
      
                           #SliderInput, in this case, let you select the time point you want to observe
                           uiOutput('xvalue')),
                         
                         #Panel principal
                         mainPanel(
                           h3(textOutput("caption")),
    
                           plotOutput("plot1"), 
    
                           tableOutput("center"),
                           
                           uiOutput("explain_center")
                           )
                         
                         )
                       
                       )
             
             
             
                       
             
             )
  
  )

