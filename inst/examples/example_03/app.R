##
## Example shiny app for queryBuilder
## Demonstrate filtering when no data frame specified
##

library(shiny)
library(queryBuilder)

server <- function(input, output) {

  output$querybuilder <- renderQueryBuilder({
    queryBuilder(filters = list(list(name = 'name', type = 'string', input = 'selectize', values = c('bob', 'alice')),
                                list(name = 'name_no_vals', type = 'string', input = 'selectize'),
                                list(name = 'id', type = 'string')),
                 autoassign = FALSE,
                 default_condition = 'AND',
                 allow_empty = TRUE,
                 display_errors = FALSE,
                 display_empty_filter = FALSE
    )
  })

  output$txtFilterList <- renderPrint({
    req(input$querybuilder_validate)
    input$querybuilder_out
  })
}

ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('querybuilder', width = 800, height = 300))
    ),
    hr(),
    h3("Output Filter List", style="color:blue"),
    verbatimTextOutput('txtFilterList')
  )
)

shinyApp(server = server, ui = ui)
