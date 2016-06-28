##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

server <- function(input, output) {
  output$q1 <- renderQueryBuilder({
    queryBuilder('m')
  })
}

ui <- shinyUI(
  fluidPage(
    queryBuilderOutput('q1')
    )
)

shinyApp(server = server, ui = ui)
