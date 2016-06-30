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
}


### Consider this:
## filter = list(name = 'mpg', type = 'string', input = 'text')
## filter = list(name = 'mpg', type = 'string', input = 'select')  # use select box
## filter = list(name = 'mpg', type = 'integer', input = 'select')  # use select box, return ref
## filter = list(name = 'mpg', type = 'string', input = 'selectize', multiple = TRUE)  # use selectize
## for select and selectize generate choices in R


ui <- shinyUI(
  fluidPage(
    fluidRow(
      column(8, queryBuilderOutput('q1'))
    ))
)

shinyApp(server = server, ui = ui)
