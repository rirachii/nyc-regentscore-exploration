##### PHASE 6 #####
# Michelle Weng
# R-Shiny code source: https://shiny.rstudio.com/articles/datatables.html

library("readxl")
library(DT)
library(shiny)

regent_2021 <- read_excel('nyc_2021.xlsx')
regent_2019 <- read_excel('nyc_2019.xlsx')
schools <- read_excel('schools.xlsx')
regent_2021 <- merge(schools,regent_2021,by="BEDS CODE")
regent_2019 <- merge(schools,regent_2019,by="BEDS CODE")
chosen <- list("NAME","SUBJECT","TOTAL TESTED","MEAN SCALE SCORE")
chosen19 <- list("NAME","SUBJECT","TOTAL TESTED","MEAN SCALE SCORE")


ui <- fluidPage(
  h2("NYC Schools Regents Score 2019 vs 2021"),
  title = "NYC Schools Regents Score 2019 vs 2021",
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        'input.dataset === "regent_2021"',
        checkboxGroupInput("show_vars", "Columns to show:",
                           names(regent_2021), selected = chosen)
      ),
      conditionalPanel(
        'input.dataset === "regent_2019"',
        checkboxGroupInput("show_vars_19", "Columns to show:",
                           names(regent_2019), selected = chosen19)
      )
    ),
    mainPanel(
      tabsetPanel(
        id = 'dataset',
        tabPanel("regent_2021", DT::dataTableOutput("mytable1")),
        tabPanel("regent_2019", DT::dataTableOutput("mytable2")),
      )
    )
  )
)

server <- function(input, output) {
  
  # diamonds2 = diamonds[sample(nrow(diamonds), 1000), ]
  output$mytable1 <- DT::renderDataTable({
    DT::datatable(regent_2021[, input$show_vars, drop = FALSE])
  })
  
  output$mytable2 <- DT::renderDataTable({
    DT::datatable(regent_2019[, input$show_vars_19, drop = FALSE], options = list(orderClasses = TRUE, pageLength = 25))
  })
  
  
}

shinyApp(ui, server)
