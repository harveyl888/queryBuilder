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

#' @import dplyr
#' @export
filterTable <- function(filters = NULL, data = NULL, output = c('table', 'text')) {
  if (is.null(filters) | is.null(data)) return(data)
  ## Run through list recursively and generate a filter
  f <- recurseFilter(filters)
  if (output == 'text') {
    return(f)
  } else if (output == 'table') {
    df <- dplyr::filter_(data, f)
    return(df)
  } else {
    return()
  }
}


# testData1 <- list(condition = 'AND',
#                   rules = list(list(id = 'disp', type = 'integer', input = 'text', operator = 'equal', value = 2),
#                   list(id = 'gear', type = 'string', input = 'select', operator = 'equal', value = '3')))
#
# testData2 <- list(condition = 'AND',
#                   rules = list(list(id = 'disp', type = 'integer', input = 'text', operator = 'equal', value = 2),
#                                list(id = 'mpg', type = 'string', input = 'text', operator = 'equal', value = '4'),
#                                list(condition = 'OR',
#                                     rules = list(list(id = 'gear', type = 'string', input = 'select', operator = 'equal', value = '3'),
#                                                  list(id = 'gear', type = 'string', input = 'select', operator = 'equal', value = '5')))))

lookup <- function(f) {
  l.operators <- list('AND' = '&', 'OR' = '|', 'equal' = '==', 'not_equal' = '!=',
                      'less' = '<', 'less_or_equal' = '<=', 'greater' = '>', 'greater_or_equal' = '>=')
  return(l.operators[[f]])
}

## recursive function to process filter
recurseFilter <- function(filter = NULL) {
  fs <- NULL
  for (i in 1:length(filter$rules)) {
    if (typeof(filter$rules[[i]]$rules) == 'list') {
      fs <- paste(fs, paste0('(', recurseFilter(filter = filter$rules[[i]]), ')'), sep = paste0(' ', lookup(filter$condition), ' '))
    } else {
      if (is.null(fs)) {
        fs <- paste(filter$rules[[i]]$id, lookup(filter$rules[[i]]$operator), filter$rules[[i]]$value)
      } else {
        fs <- paste(fs, paste(filter$rules[[i]]$id, lookup(filter$rules[[i]]$operator), filter$rules[[i]]$value), sep = paste0(' ', lookup(filter$condition), ' '))
      }
    }
  }
  return(fs)
}
#recurseFilter(testData2)



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
