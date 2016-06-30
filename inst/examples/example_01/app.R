##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

server <- function(input, output) {
  output$q1 <- renderQueryBuilder({
    queryBuilder(data = mtcars, filters = list(c(name = 'mpg', type = 'string'),
                                               c(name = 'disp', type = 'integer', min=0, max=5, step=2))
    )
  })
}

ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('q1'))
    ))
)

shinyApp(server = server, ui = ui)
