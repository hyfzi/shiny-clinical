library(shiny)
library(ggplot2)
library(tidyverse)
library(shinydashboard)
library(teal.data)
library(teal.modules.clinical)
library(nestcolor)

# path <- system.file("AE", "/Users/zhiyi/Documents/rshiny_tutorial/final/data/AE.sas7bdat", package = "haven")
# read_sas(path)
# adamdir <- list.files("/Users/zhiyi/Documents/rshiny_tutorial/final/data", pattern = "*.sas7bdat$", full.names = T)

# ae <- read_sas("/Users/zhiyi/Documents/rshiny_tutorial/final/data/ae.sas7bdat")
# dm <- read_sas("/Users/zhiyi/Documents/rshiny_tutorial/final/data/dm.sas7bdat")


adae <- tmc_ex_adae
# ae1 <- ae %>% select(-c('DOMAIN', 'STUDYID')) %>% left_join(dm, by = "USUBJID")


server <- function(input, output) {

  data <- adae
  data1 <-reactive({
    
    # 确保input$siteid是有值的
    req(input$varvalue1)
    if(input$varvalue1 == "ALL" && input$varvalue2 == "ALL" ){
      data
    }
    else if (input$varvalue1 != "ALL" || input$varvalue2 != "ALL" ){
      if (input$varvalue1 != "ALL" && input$varvalue2 == "ALL"){
        data %>% filter(!!sym(input$var1) == input$varvalue1)
      }
      else if(input$varvalue1 == "ALL" && input$varvalue2 != "ALL" ){
        data %>% filter(!!sym(input$var2) == input$varvalue2)
      }
      else if(input$varvalue1 != "ALL" || input$varvalue2 != "ALL" )
        data %>% filter(!!sym(input$var2) == input$varvalue2) %>% filter(!!sym(input$var1) == input$varvalue1)
    }
  }
  )
  
  aenum <- reactive({
    data1() %>% summarise(count = n())
  })
  
  saenum <- reactive({
    data1() %>% filter(AESER == "Y") %>% summarise(count = n())
  })
  
  daenum <- reactive({
    data1() %>% filter(!is.na(DTHDT)) %>% summarise(count = n())
  })
  
  graph1 <- reactive({
    d1 <- data1() %>% group_by(AEREL) %>% summarise(grp = 'grp1', count1 = n_distinct(AETERM))
    d2 <-data1() %>% group_by(AEREL) %>% summarise(grp = 'grp2', count1 = n_distinct(USUBJID))
    union(d1, d2)
  })
  
  varname1 <- reactive({
    input$var1
  })
  
  varname2 <- reactive({
    input$var2
  })

  output$varvalue1 <- renderUI({
    columname <- varname1()
    datavalue <- data %>% select(columname) 
    choices <- (unique(datavalue))
    # 仔细理解一下
    # print(choices)
    # print(nrow(choices))
    
    if(nrow(choices) == 1)
      choices <- as.character(unique(datavalue))
    else
      choices <- as.list(unique(datavalue))
    
    selectInput("varvalue1", "选择变量值1", choices = c("ALL",choices))
  })
  
  output$varvalue2 <- renderUI({
    columname <- varname2()
    datavalue <- data %>% select(columname) 
    choices <- (unique(datavalue))
    
    if(nrow(choices) == 1)
      choices <- as.character(unique(datavalue))
    else
      choices <- as.list(unique(datavalue))
    
    selectInput("varvalue2", "选择变量值2", choices = c("ALL",choices))
  })
  
  output$AE <- renderValueBox({
    valueBox("# 不良事件",
            value = aenum()$count)
  })
  
  output$SAE <- renderValueBox({
    valueBox("# 严重不良事件",
             value = saenum()$count)
  })
  
  output$AE2 <- renderValueBox({
    valueBox("# 致死的不良事件",
             value = daenum()$count)
  })
  
  output$plot1 <- renderPlot({
    ggplot(data1(), aes(y = data1()$SITEID)) + geom_bar(stat = "count")
  })
  
  output$plot2 <- renderPlot({
    ggplot(graph1(), aes(x = graph1()$AEREL, y = graph1()$count1, fill = graph1()$grp)) + 
      geom_bar(stat = "identity", position = 'dodge')
  })
  
  output$plot3 <- renderPlot({
    ggplot(data1(), aes(y = data1()$AESOC, fill = data1()$AETOXGR)) + 
      geom_bar(stat = "count", position = 'stack')
  })
  
  output$plot4 <- renderPlot({
    ggplot(data1(), aes(y = data1()$AEDECOD, fill = data1()$AETOXGR)) + 
      geom_bar(stat = "count", position = 'stack')
  })
  
  output$AETS <- DT::renderDataTable({data1()})
  
}

