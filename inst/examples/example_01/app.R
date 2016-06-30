##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

server <- function(input, output) {
  output$q1 <- renderQueryBuilder({
    queryBuilder(data = mtcars, filters = list(list(name = 'mpg', type = 'string', input = 'text'),
                                               list(name = 'disp', type = 'integer', input = 'text', min=0, max=5, step=2),
                                               list(name = 'gear', type = 'string', input = 'select'))
    )
  })

  output$txt1 <- renderPrint(input$q1_out)
}

ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('q1')),
      verbatimTextOutput('txt1')
    ))
)

shinyApp(server = server, ui = ui)
