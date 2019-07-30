## Inividual data explorer for the ReplaceBGDataset 
# a collab by JCD and RH

## libs 
library(dplyr)
library(tidyr)
library(shiny)
library(gridExtra)
library(ggplot2)

## load dataset
# t1 = Sys.time()
load("~/ReplaceBG/DataTables/ReplaceBGDataset.Rdata") # 1ish seconds NICE!
# t2 = Sys.time()
# t2-t1

## source helper functions
## Idea here is we could have some helper functions that we source specifically for htis project all of the ui stuff basically

ui <- fluidPage(
  
  # App title ----
  titlePanel("Shiny test"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      helpText("test"),
      
      # Input: select subject ----
      selectInput(inputId = "ID",
                  label = "Select Subject",
                  choices = ReplaceBGDataset$PtID),
      
      # # Input: days since enrollment
      uiOutput("dateRange")
      
      # this is now in the server side
      # sliderInput(inputId = 'dateRange',
      #             label = 'Days Since Enrolment',
      #             value = c(max(ReplaceBGDataset$BGMdata[[ID]]$DeviceDtTmDaysFromEnroll) - 60, max(ReplaceBGDataset$BGMdata[[ID]]$DeviceDtTmDaysFromEnroll)),
      #             min = min(ReplaceBGDataset$BGMdata[[ID]]$DeviceDtTmDaysFromEnroll),
      #             max = max(ReplaceBGDataset$BGMdata[[ID]]$DeviceDtTmDaysFromEnroll)
      # )
      # 
    ), # side bar panesl
    
    
    # plot output 
    mainPanel(
      
      textOutput('text'), # for debug stuff will remove later
      plotOutput('plot') # for plots 
      
    ) 
  ) #  sidebar layout
  
) # page 

## libs
library(dplyr)
library(tidyr)

# Define server logic ---
server <- function(input, output){
  
  # loading twice is not good think of a better way to do this 
  # one idea is to use something similar to the render UI functions to get send all the relevant UI data from server side
  load("~/ReplaceBG/DataTables/ReplaceBGDataset.Rdata")
  
  # this is for bug testing it will be removed in final version
  output$text = renderText({paste(class(input$ID),nrow(dataset_BGM()), class(min_date_range()), max_date_range(), 
                                  input$daysfromenroll[1],class(input$daysfromenroll[1]) , class(input$daysfromenroll[2]))
  })
  
  
  # this takes the input from subject filters the data and figures out hte best range
  # grab data frames
  dataset_CGM <- reactive({
    ReplaceBGDataset$CGMdata[[as.numeric(input$ID)]]
  })
  
  dataset_BGM <- reactive({
    ReplaceBGDataset$BGMdata[[as.numeric(input$ID)]]
  })
  
  # range is calculated on the CGM data
  min_date_range <- reactive({
    tmp = dataset_CGM()
    min(tmp$DeviceDtTmDaysFromEnroll)
  })
  
  max_date_range <- reactive({
    tmp = dataset_CGM()
    max(tmp$DeviceDtTmDaysFromEnroll)
  })
  
  ## make the ui for date range
  output$dateRange <- renderUI({
    sliderInput(inputId = "daysfromenroll",
                label = "Days From Enroll Range",
                min = min_date_range(),
                max = max_date_range(),
                value = c(max_date_range() - 60, max_date_range()) # final 60 days default
                )
  })
  
  # Define plot logic ---
  output$plot <- renderPlot({

    # use reactive plots by putting each plot in a reactive bracket
    # CGM plots 
    p1 <- reactive({
      tmp = dataset_CGM()
      d1 = filter(tmp, DeviceDtTmDaysFromEnroll >= input$daysfromenroll[1] & DeviceDtTmDaysFromEnroll <= input$daysfromenroll[2] )
      ggplot(data = d1, aes(y = GlucoseValue, x = seq_along(GlucoseValue))) +
        geom_point() + 
        labs(title = paste("CGM data")) # need better x axis labels
      # plot(d1$GlucoseValue)
    })
    
    # BGM plots 
    p2 <- reactive({
      tmp = dataset_BGM()
      d1 = filter(tmp, DeviceDtTmDaysFromEnroll >= input$daysfromenroll[1] & DeviceDtTmDaysFromEnroll <= input$daysfromenroll[2] )
      ggplot(data = d1, aes(y = GlucoseValue, x = seq_along(GlucoseValue))) +
        geom_point() + 
        labs(title = paste("BGM data")) # need better x axis labels
      # plot(d1$GlucoseValue)
    })
    
    # histogram
    p3 <- reactive({
      
      tmp1 = dataset_BGM() # get data 
      tmp1$Measurement = "BGM"
      tmp2 = dataset_CGM() # get data 
      tmp2$Measurement = "CGM"
      tmp3 = full_join(tmp1,tmp2,by = c("DeviceDtTmDaysFromEnroll", "DeviceTm", "Measurement", "GlucoseValue"))
      # plot
      ggplot(data = tmp3, aes(x = GlucoseValue, fill = Measurement)) + 
        geom_histogram( bins = 30, alpha = 0.5)
    })
    
    # arrange
    ptlist <- list(p1(), p2(), p3())
    grid.arrange(grobs = ptlist,nrow=3,ncol=1)
    

  })
  
}

shinyApp(ui = ui, server = server) # start app
