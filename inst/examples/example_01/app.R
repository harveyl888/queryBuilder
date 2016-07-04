##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

server <- function(input, output) {
  output$q1 <- renderQueryBuilder({
    queryBuilder(data = mtcars, filters = list(list(name = 'mpg', type = 'double', min=min(mtcars$mpg), max=max(mtcars$mpg), step=0.1),
                                               list(name = 'disp', type = 'integer', min=60, max=200, step=1),
                                               list(name = 'gear', type = 'string', input = 'select'))
    )
  })

  output$txt1 <- renderPrint(filterTable(input$q1_out, mtcars, 'text'))
  output$txt2 <- renderPrint(jsonlite::prettify(input$q1_filters))

  output$dt <- renderTable({
    req(input$q1_validate)
    filterTable(input$q1_out, mtcars, 'table')
  })
}

ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('q1'),
             tableOutput('dt')
      ),
      verbatimTextOutput('txt1'),
      verbatimTextOutput('txt2')
    )
  )
)

shinyApp(server = server, ui = ui)
