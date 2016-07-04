##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

server <- function(input, output) {
  output$q1 <- renderQueryBuilder({
    queryBuilder(data = mtcars, filters = list(list(name = 'mpg', type = 'string', input = 'text'),
                                               list(name = 'disp', type = 'integer', min=0, max=5, step=2),
                                               list(name = 'gear', type = 'string', input = 'select'))
    )
  })

  output$txt1 <- renderPrint(input$q1_validate)

  output$dt <- renderTable({
    filterTable(input$q1_out, mtcars)
  })
}

ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('q1')),
      verbatimTextOutput('txt1')
    ),
    tableOutput('dt')
  )
)

shinyApp(server = server, ui = ui)
