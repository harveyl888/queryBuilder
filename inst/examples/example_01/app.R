##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

df.data <- mtcars
df.data$name <- row.names(df.data)

server <- function(input, output) {

  output$q1 <- renderQueryBuilder({
    queryBuilder(data = df.data, filters = list(list(name = 'mpg', type = 'double', min=min(mtcars$mpg), max=max(mtcars$mpg), step=0.1),
                                                list(name = 'disp', type = 'integer', min=60, step=1),
                                                list(name = 'gear', type = 'string', input = 'select', operators = c('equal', 'not_equal')),
                                                list(name = 'name', type = 'string', operators = c('begins_with', 'not_begins_with', 'ends_with', 'not_ends_with')))
    )
  })

  output$txt1 <- renderPrint(jsonlite::prettify(input$q1_filters))
  output$txt2 <- renderPrint(filterTable(input$q1_out, df.data, 'text'))

  output$dt <- renderTable({
    req(input$q1_validate)
    filterTable(input$q1_out, df.data, 'table')
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
