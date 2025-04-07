library(KMsurv)
library(survival)
library(shiny)
library(ggplot2)
library(plyr)


shinyServer(function(input, output, session) {
  
  sheets <- reactive({
    req(input$file)  # Ensure a file is uploaded
    excel_sheets(input$file$datapath)  # Get sheet names
  })
  
    
  
  
  
  
  
  
  # Update sheet selection input
  output$sheet_select <- renderUI({
    req(sheets)  # Ensure sheets are available
    selectInput("sheet", "Select Sheet", choices = sheets())
  })
  
  df <- reactive({
    req(input$sheet)
    as.data.frame(read_xlsx(input$file$datapath, sheet = input$sheet))
  })
  
  
  #Once sheet is selected
  output$time_select <- renderUI({
    req(df())
    selectInput("time","Time variable:", names(df()))
  })
  
  output$delta_select <- renderUI({
    req(df())
    selectInput("delta", "Delta variable:", names(df()))
  })
 

  
  
  
  
  
  #Second selection for fit
  output$sur_var <- renderUI({
    req(df())
    req(input$charge)
    selectInput("sur_var", "Factor of survival:",   names(df())[names(df())!= input$time & names(df()) != input$delta])
  })
  
  output$xvalue <- renderUI({
    req(input$charge)
    sliderInput('xvalue', 'Survival Days = ',value=max(df()[,c(input$time)]), min=1, max=max(df()[,c(input$time)]))
  })
  
  output$reload <- renderUI({
    req(input$charge)
    actionButton("varSelected", "Reload")
  })
  
  
  
  
  
  
  # Combine the selected variables into a new data frame
  df_reducted <- reactive({
    req(df())
    req(input$sur_var)
    req(input$varSelected)
    df()[, c(input$time, input$delta, input$sur_var)]
  })
  
  selectedData <- reactive({
    req(input$sur_var)
    as.factor(df()[,c(input$sur_var)])
  })
  
  informationDf <- reactive({
    req(runSur())
    as.data.frame(summary(runSur())[1:10])
  })
  
  
  
  
  
  
  
  
  
  
  # Running the survival function
  runSur <- reactive({
    req(df_reducted())
    req(input$sur_var)
    req(input$varSelected)
    survfit( as.formula(paste("Surv(", paste(input$time),"," , paste(input$delta), ") ~ ", paste(input$sur_var))), data=df_reducted())
  })
  
  # Running survival difference 
  diffSur <- reactive({
    req(runSur())
    survdiff(as.formula(paste("Surv(", paste(input$time),"," , paste(input$delta), ") ~ ", paste(input$sur_var))), data=df_reducted())
  })
  
  
  
  
  
  # This is a caption that will show on top of the graph; the name will change based on which variable you choose
  output$caption <- renderText({
    req(input$sur_var)
    paste("Survival Graph of", input$sur_var,"(p-val = " , round(diffSur()$pvalue, 2),")",sep="\n")
  })
  
  
  # Plot the survival graph
  output$plot1 <- renderPlot({
    plot(runSur(), 
        col=c("red","sky blue","green","purple","orange","yellow"), xlab="Time", ylab="S(t) [Prob]")
    legend("bottomleft",cex=0.9,legend = levels(selectedData()),fill= c("red","sky blue","green","purple","orange","yellow"))
    abline(v=input$xvalue,col=1,lty=2)
    })
  
  
  # This table will give you the probability of survival for each class at a given time
  output$center <- renderTable({
    informationDf()
  })
  
  output$explain_center <- renderUI({
    req(input$varSelected)
    
    HTML(paste(
      "<h3>Variable explanation</h3>",
      
      "<h4>This table helps you to:</h4>",
      "<ul>",
      "<li><strong>Understand the survival experience of different patient groups (strata).</strong></li>",
      "<li><strong>Track how survival changes over time.</strong></li>",
      "<li><strong>Assess the risk of the event of interest occurring.</strong></li>",
      "<li><strong>Evaluate the reliability of the survival estimates.</strong></li>",
      "</ul><br>",
      
      
      
      "<h4>Explanations for Kaplan-Meier comparation variables table:</h4>",
      "<ul>",
      "<li><strong>n (Number of Patients):</strong> This is the total number of patients included in the specific group being analyzed. Think of it as the starting point for your analysis.</li>",
      "<li><strong>time (Time Point):</strong> This column represents the specific time point at which the survival analysis is being evaluated. It's the 'x-axis' of your Kaplan-Meier curve. This tells you how long after the start of the study (or treatment) the data is being looked at.</li>",
      "<li><strong>n.risk (Number at Risk):</strong> This is the number of patients who are still being followed at that specific time point. It's crucial to understand that this number decreases over time as patients experience the event of interest or are lost to follow-up.</li>",
      "<li><strong>n.event (Number of Events):</strong> This column indicates the number of patients who experienced the event of interest at that specific time point. This is the key outcome we're tracking in survival analysis.</li>",
      "<li><strong>n.censor (Number Censored):</strong> This is the number of patients who were lost to follow-up or withdrew from the study at that time point. Censoring is a common occurrence in survival analysis and needs to be accounted for.</li>",
      "<li><strong>surv (Survival Probability):</strong> This is the estimated probability of a patient surviving <em>beyond</em> that specific time point. It's expressed as a decimal. This is the core information you'll use to understand patient outcomes.</li>",
      "<li><strong>std.err (Standard Error of Survival):</strong> This reflects the uncertainty or variability around the survival probability estimate. Think of it as a measure of how precise the survival estimate is. Smaller standard errors indicate more reliable estimates.</li>",
      "<li><strong>cumhaz (Cumulative Hazard):</strong> This represents the accumulated risk of the event of interest occurring up to that specific time point. It's related to survival probability but is often used in more advanced statistical modeling. A higher cumulative hazard means a higher risk of the event.</li>",
      "<li><strong>std.chaz (Standard Error of Cumulative Hazard):</strong> Similar to the standard error of survival, this reflects the uncertainty around the cumulative hazard estimate.</li>",
      "<li><strong>strata (Stratification Variable):</strong> This column indicates the subgroups being compared. Stratification allows you to see how different patient characteristics influence survival.</li>",
      "</ul>",
      
      sep = "\n"
    ))
  })
})


























