#' queryBuilder
#'
#' create a queryBuilder widget from a series of filters
#'
#' @param data data frame
#' @param filters list of lists containing filter parameters
#'
#' @import htmlwidgets
#'
#' @export
queryBuilder <- function(data = NULL, filters = list(), width = NULL, height = NULL) {

  if (is.null(data)) return()
  if (length(filters) == 0) return()
  if (!all(sapply(filters, function(x) x['name']) %in% names(data))) return()

  for (i in 1:length(filters)) {
    if (filters[[i]]['input'] == 'select') {
      filters[[i]][['values']] <- unique(data[[filters[[i]][['name']]]])
    }
  }

  # forward options using x
  x = list(
    data = filters
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'queryBuilder',
    x,
    width = width,
    height = height,
    package = 'queryBuilder'
  )
}

#' @export
filterTable <- function(filters = NULL, data = NULL) {
  if (is.null(filters) | is.null(data)) return(data)

  ## Loop through list
  ## Currently works on linear list (no groups, no recursion)
  cond <- filters['condition']
  return(cond)

}


## recursive function to process filter
recurseFilter <- function(condition = 'AND', filter = NULL) {
  fs <- ''
  for (i in 1:length(filter)) {
    if (typeof(filter[[i]]) == 'list') {
      fs <- paste0(fs, recurseFilter(condition = condition, filter = filter[[i]]))
    } else {
      fs <- paste(fs, filter[[i]])
    }
  }
  return(fs)
}

## Test the recursion
recurseFilter(condition = 'AND', filter = list('A', 'B', list('C', 'D')))




#' Shiny bindings for queryBuilder
#'
#' Output and render functions for using queryBuilder within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a queryBuilder
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name queryBuilder-shiny
#'
#' @export
queryBuilderOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'queryBuilder', width, height, package = 'queryBuilder')
}

#' @rdname queryBuilder-shiny
#' @export
renderQueryBuilder <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, queryBuilderOutput, env, quoted = TRUE)
}
