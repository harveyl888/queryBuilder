##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)
library(jsonlite)

df.data <- data.frame(sapply(seq(16), function(x) runif(20, 1, 10)))
names(df.data) <- paste0('Sample_', seq(16))
for (i in 1:4) {
  df.data[[paste0('AV_group_', i)]] <- rowMeans(df.data[, ((i-1)*4+1):(i*4)])
}
df.data <- df.data[, grep('AV_', names(df.data))]

server <- function(input, output) {

  output$querybuilder <- renderQueryBuilder({
    queryBuilder(data = df.data, filters = list(list(name = 'Trend', type = 'string', input = 'function_0'),
                                                list(name = 'AV_group_1', type = 'string', input = 'group'),
#                                                list(name = 'AV_group_2', type = 'string', input = 'group'),
                                                list(name = 'AV_group_2', type = 'string', input = 'selectize'),
                                                list(name = 'AV_group_3', type = 'string', input = 'group'),
                                                list(name = 'AV_group_4', type = 'string', input = 'group')),
                 autoassign = FALSE,
                 default_condition = 'AND',
                 allow_empty = TRUE,
                 display_errors = TRUE,
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
