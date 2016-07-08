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
    if (filters[[i]]['input'] %in% c('select', 'selectize')) {
      uniqueVals <- unique(data[[filters[[i]][['name']]]])
      uniqueVals <- sort(uniqueVals[!is.na(uniqueVals)])  # sort and get rid of NA value if present
      filters[[i]][['values']] <- uniqueVals
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

#' filterTable
#'
#' filter a data frame using the output of a queryBuilder htmlWidget
#'
#' @param filters output from queryBuilder htmlWidget sent from shiny app as \code{input$el_out} where \code{el} is the htmlWidget element
#' @param data data frame to filter
#' @param output string return either a filtered data frame (table) or a text representation of the filter (text)
#'
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


#' lookup
#'
#' internal function to create a filter condition based on id, operator and value
#'
#' @param id data frame column id
#' @param operator filter operator as defined within queryBuilder
#' @param value filter value
#' @return string representation of a single filter
#'
lookup <- function(id, operator, value) {
  ## triple style operator, eg a = 1
  l.operators1 <- list('equal' = '==', 'not_equal' = '!=', 'less' = '<', 'less_or_equal' = '<=', 'greater' = '>', 'greater_or_equal' = '>=')
  ## functional style operator, eg startswith(a, value)
  l.operators2 <- list('begins_with' = 'startsWith', 'not_begins_with' = '!startsWith', 'ends_with' = 'endsWith', 'not_ends_with' = '!endsWith')
  ## grep style operator, eg grepl(value, a)
  l.operators3 <- list('contains' = 'grepl', 'not_contains' = '!grepl')
  ## two-value style operator, eg a > 10 & a < 20
  l.operators4 <- list('between' = 'between', 'not_between' = 'not_between')
  ## simple boolean function, eg is.na(a)
  l.operators5 <- list('is_na' = 'is.na', 'is_not_na' = '!is.na')
  ## operators acting on multiple values
  l.operators6 <- list('in' = '%in%', 'not_in' = '!%in%')

  if (operator %in% names(l.operators1)) {
    return(paste(id, l.operators1[[operator]], value))
  }
  if (operator %in% names(l.operators2)) {
    return(paste0(l.operators2[[operator]], '(', id, ', \"', value, '\")'))
  }
  if (operator %in% names(l.operators3)) {
    return(paste0(l.operators3[[operator]], '(\"', value, '\", ', id, ')'))
  }
  if (operator %in% names(l.operators4)) {
    if (operator == 'between') {
      return(paste0(id, ' >= ', value[[1]], ' & ', id, ' <= ', value[[2]]))
    } else {
      return(paste0('!(', id, ' >= ', value[[1]], ' & ', id, ' <= ', value[[2]], ')'))
    }
  }
  if (operator %in% names(l.operators5)) {
    return(paste0(l.operators5[[operator]], '(', id, ')'))
  }
  if (operator %in% names(l.operators6)) {
    if (operator == 'in') {
      return(paste0(id, ' %in% c(', paste(value, collapse = ', '), ')'))
    } else {
      return(paste0('!(', id, ' %in% c(', paste(value, collapse = ', '), '))'))
    }
  }
}

#' recurseFilter
#'
#' internal recursive function to process filter
#'
#' @param filter filters output from queryBuilder htmlWidget
#' @return string representation of all filters combined
#'
recurseFilter <- function(filter = NULL) {
  condition <- list('AND' = '&', 'OR' = '|')
  fs <- NULL
  for (i in 1:length(filter$rules)) {
    if (typeof(filter$rules[[i]]$rules) == 'list') {
      fs <- paste(fs, paste0('(', recurseFilter(filter = filter$rules[[i]]), ')'), sep = paste0(' ', condition[[filter$condition]], ' '))
    } else {
      if (filter$rules[[i]]$type == 'date') {  # treat dates
        if (length(filter$rules[[i]]$value) > 1) {
          value <- lapply(filter$rules[[i]]$value, function(x) paste0('as.Date(\"', x, '\")'))  # date range
        } else {
          value <- paste0('as.Date(\"', filter$rules[[i]]$value, '\")')  # single date
        }
      } else {
        value = filter$rules[[i]]$value
      }
      if (is.null(fs)) {
        fs <- lookup(filter$rules[[i]]$id, filter$rules[[i]]$operator, value)
      } else {
        fs <- paste(fs, lookup(filter$rules[[i]]$id, filter$rules[[i]]$operator, value), sep = paste0(' ', condition[[filter$condition]], ' '))
      }
    }
  }
  return(fs)
}



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
