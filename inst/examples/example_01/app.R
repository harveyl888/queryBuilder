##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

server <- function(input, output) {
  output$q1 <- renderQueryBuilder({
    queryBuilder::queryBuilder(data = mtcars, filters = c('mpg', 'disp'), type = c('string', 'string'))
  })
}

ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('q1'))
    ))
)

shinyApp(server = server, ui = ui)
