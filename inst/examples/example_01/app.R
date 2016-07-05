##
## Example shiny app for queryBuilder
##

library(shiny)
library(queryBuilder)

df.data <- mtcars
df.data$name <- row.names(df.data)
df.data[2:3, 'gear'] <- NA

server <- function(input, output) {

  output$q1 <- renderQueryBuilder({
    queryBuilder(data = df.data, filters = list(list(name = 'mpg', type = 'double', min=min(mtcars$mpg), max=max(mtcars$mpg), step=0.1),
                                                list(name = 'disp', type = 'integer', min=60, step=1),
                                                list(name = 'gear', type = 'string', input = 'select'),
                                                list(name = 'name', type = 'string'))
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
