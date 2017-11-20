##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)
library(jsonlite)

df.data <- mtcars
df.data$name <- row.names(df.data)
df.data$nameFactor <- as.factor(df.data$name)
df.data$date <- sample(seq(as.Date('2016/01/01'), as.Date('2016/01/20'), by="day"), nrow(df.data), replace = TRUE)
df.data$vs <- as.integer(df.data$vs)
df.data$logical <- df.data$carb < 4
df.data[2:3, 'gear'] <- NA

server <- function(input, output) {

  output$querybuilder <- renderQueryBuilder({
    queryBuilder(data = df.data, filters = list(list(name = 'mpg', type = 'double', min=min(mtcars$mpg), max=max(mtcars$mpg), step=0.1),
                                                list(name = 'disp', type = 'integer', min=60, step=1),
                                                list(name = 'gear', type = 'integer', input = 'select', values = c(2, 3, 4)),
                                                list(name = 'name', type = 'string'),
                                                list(name = 'nameFactor', type = 'string', input = 'selectize'),
                                                list(name = 'date', type = 'date', mask = 'yy-mm-dd'),
                                                list(name = 'logical', type = 'boolean', input = 'radio'),
                                                list(name = 'carb', type = 'string', input = 'selectize')),
                 autoassign = FALSE,
                 default_condition = 'AND',
                 allow_empty = TRUE,
                 display_errors = FALSE,
                 display_empty_filter = FALSE
    )
  })

  output$txtValidation <- renderUI({
    if(input$querybuilder_validate == TRUE) {
      h3('VALID QUERY', style="color:green")
    } else {
      h3('INVALID QUERY', style="color:red")
    }
  })

  output$txtFilterText <- renderUI({
    req(input$querybuilder_validate)
    h4(span('Filter sent to dplyr: ', style="color:blue"), span(filterTable(input$querybuilder_out, df.data, 'text'), style="color:green"))
  })

  output$txtFilterList <- renderPrint({
    req(input$querybuilder_validate)
    input$querybuilder_out
  })


  output$dt <- renderTable({
    req(input$querybuilder_validate)
    df <- filterTable(input$querybuilder_out, df.data, 'table')
    df$date <- strftime(df$date, format="%Y-%m-%d")
    df
  })
}

ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('querybuilder', width = 800, height = 300)),
      column(2, uiOutput('txtValidation'))
    ),
    hr(),
    uiOutput('txtFilterText'),
    hr(),
    h3("Output Table", style="color:blue"),
    fluidRow(tableOutput('dt')),
    hr(),
    h3("Output Filter List", style="color:blue"),
    verbatimTextOutput('txtFilterList')
  )
)

shinyApp(server = server, ui = ui)
