library(haven)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(nestcolor)
library(teal.modules.clinical)
# ae <- read_sas("/Users/zhiyi/Documents/rshiny_tutorial/final/data/ae.sas7bdat")
# dm <- read_sas("/Users/zhiyi/Documents/rshiny_tutorial/final/data/dm.sas7bdat")
# ae1 <- ae %>% select(-c('DOMAIN', 'STUDYID')) %>% left_join(dm, by = "USUBJID")
# data <- ae1

format.func <- "
<script type='text/javascript'>
function format ( d ) {
    return '<table cellpadding=\"5\" cellspacing=\"0\" border=\"0\" style=\"padding-left:50px;\">'+
        '<tr>'+
            '<td>Full name:</td>'+
            '<td>'+d[1]+'</td>'+
        '</tr>'+
        '<tr>'+
            '<td>Extension number:</td>'+
            '<td>'+d[4]+'</td>'+
        '</tr>'+
    '</table>';
}
</script>
"

adae <- tmc_ex_adae
ui <- dashboardPage(
  dashboardHeader(title = "Medical Monitoring"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("不良事件", tabName = "AE")
    ),
    sidebarMenu(
      menuItem("不良事件表格", tabName = "AETable")
    )
  ),
  dashboardBody(
    tabItems(
      
      tabItem(
        tabName = "AE",
        fluidRow(
          column(
            2,
            box(selectInput("var1", "添加筛选条件1", choices = c(as.list(names(adae)))),
                uiOutput("varvalue1"), width = 12),
          ),
          column(
            2,
            box(selectInput("var2", "添加筛选条件2", choices = c(as.list(names(adae)))),
                uiOutput("varvalue2"), width = 12),
          ),
          
        ),
        fluidRow(
          column(6,
                 valueBoxOutput("AE", width = 4),
                 valueBoxOutput("SAE", width = 4),
                 valueBoxOutput("AE2", width = 4),
                 box(plotOutput("plot2", height = 200), width = 12)
          ),
          column(6,
                 box(plotOutput("plot1", height = 320), width = 12)
          )
        ),
        fluidRow(
          column(6,
                 box(plotOutput("plot3", height = 250), width = 12)),
          column(6,
                 box(plotOutput("plot4", height = 250), width = 12)),
          
        )
      ),
      
      # AETable
      tabItem(tabName = "AETable", h1("不良事件列表"),
              DT::dataTableOutput("AETS"))
    )
  )
)