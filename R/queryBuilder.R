#' queryBuilder
#'
#' create a queryBuilder widget from a series of filters
#'
#' @param data data frame (optional) used when autoassign is true
#' @param filters list of lists containing filter parameters
#' @param autoassign Boolean.  If true then filter names and types will be assigned based on data frame.  In order to use
#'     this `data` must also be supplied
#' @param rules A list of queryBuilder rules
#' @param default_condition supply the default condition (`AND` or `OR`)
#' @param allow_empty Boolean.  If true then no validation error is thrown when the builder is entirely empty
#' @param display_errors Boolean.  If true then an icon and tooltip explaining the error will be displayed
#' @param display_empty_filter Boolean.  If true then empty option will be included for each rule.  If false
#'     then the first filter will be selected when creating the rule
#' @param chosen Boolean.  If true then use jquery chosen (https://github.com/harvesthq/chosen) to select filter for rules
#'
#' @import htmlwidgets
#'
#' @export
queryBuilder <- function(data = NULL,
                         filters = list(),
                         autoassign = FALSE,
                         rules = NULL,
                         default_condition = 'AND',
                         allow_empty = FALSE,
                         display_errors = TRUE,
                         display_empty_filter = TRUE,
                         chosen = FALSE,
                         width = NULL,
                         height = NULL) {

  if (!length(rules)) rules <- NULL

  if(autoassign == TRUE) {
    if (is.null(data)) return(NULL)
    filters <- list()
    columnTypes <- sapply(data, class)
    for (i in seq_along(columnTypes)) {
      c <- columnTypes[i]
      if(c == 'numeric') {
        filters[[length(filters) + 1]] <- list(name = names(c), type = 'double')
      } else if (c == 'integer') {
        filters[[length(filters) + 1]] <- list(name = names(c),
                                               type = 'integer')
      } else if (c == 'character') {
        filters[[length(filters) + 1]] <- list(name = names(c), type = 'string')
      } else if (c == 'factor') {
        filters[[length(filters) + 1]] <- list(name = names(c), type = 'string',
                                               input = 'selectize')
      } else if (c == 'Date') {
        filters[[length(filters) + 1]] <- list(name = names(c), type = 'date')
      } else if (c == 'logical') {
        filters[[length(filters) + 1]] <- list(name = names(c),
                                               type = 'boolean',
                                               input = 'radio',
                                               values = c(TRUE, FALSE))
      }
    }
  } else {
    if (length(filters) == 0) return()  # No filters - do not construct
#     nonFunctionFilters <- unlist(lapply(filters, function(x) if(!x$input %in% c('function_0')) x$name))
#     if (!all(nonFunctionFilters %in% names(data))) return()
  }

  for (i in seq_along(filters)) {
    if (filters[[i]]['input'] %in% c('select', 'selectize', 'radio')) {
      if (!'values' %in% names(filters[[i]])) {
        if (is.null(data) | !filters[[i]][['name']] %in% names(data)) {
          filters[[i]]['input'] <- NULL  ## no choices available - reset input
        } else {
          uniqueVals <- unique(data[[filters[[i]][['name']]]])
          uniqueVals <- sort(uniqueVals[!is.na(uniqueVals)])  # sort and get rid of NA value if present
          filters[[i]][['values']] <- as.list(uniqueVals)
        }
      }
    }
  }

  settings = list(default_condition = default_condition,
                  allow_empty = allow_empty,
                  display_errors = display_errors,
                  display_empty_filter = display_empty_filter,
                  chosen = chosen)

  # forward options using x
  x = list(
    data = filters,
    rules = rules,
    settings = settings
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
#' @import rlang
#'
#' @export
filterTable <- function(filters = NULL, data = NULL, output = c('table', 'text')) {
  output <-  match.arg(output)
  if (is.null(filters) || !length(filters) || is.null(data)) return(data)
  ## Run through list recursively and generate a filter
  f <- recurseFilter(filters)
  if (output == 'text') {
    return(f)
  } else if (output == 'table') {
    df <- data %>% dplyr::rowwise() %>% dplyr::filter(!!rlang::parse_expr(f))
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
  id <- paste0("`", id, "`")
  ## triple style operator, eg a = 1
  l.operators1 <- list('equal' = '==', 'not_equal' = '!=', 'less' = '<', 'less_or_equal' = '<=', 'greater' = '>', 'greater_or_equal' = '>=',
                       'equal_' = '==', 'not_equal_' = '!=', 'less_' = '<', 'less_or_equal_' = '<=', 'greater_' = '>', 'greater_or_equal_' = '>=')
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
  ## operators based on a trend
  l.operators7 <- list('up' = 'upTrend', 'down' = 'downTrend')

  # javascript boolean to R boolean
  if (value %in% c('true', 'false')) { value <- toupper(value) }

  if (operator %in% names(l.operators1)) {
    if (substring(operator, nchar(operator)) == '_') {
      return(paste0(id, l.operators1[[operator]], ' `', value, '`'))
    } else {
      return(paste0(id, l.operators1[[operator]], ' ', value))
    }
  }
  if (operator %in% names(l.operators2)) {
    return(paste0(l.operators2[[operator]], '(', id, ', ', value, ')'))
  }
  if (operator %in% names(l.operators3)) {
    return(paste0(l.operators3[[operator]], '(', value, ', ', id, ')'))
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
  if (operator %in% names(l.operators7)) {
    return(paste0('queryBuilder::', l.operators7[[operator]], '(', paste(gsub('\"', '`', value), collapse = ', '), ')'))
    ## Need to add namespace for defined functions for dplyr filter_ to work
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
  for (i in seq_along(filter$rules)) {
    if (typeof(filter$rules[[i]]$rules) == 'list') {  # nested filter group
      if (is.null(fs)) {
        fs <- paste0('(', recurseFilter(filter = filter$rules[[i]]), ')')  # first filter
      } else {
        fs <- paste(fs, paste0('(', recurseFilter(filter = filter$rules[[i]]), ')'), sep = paste0(' ', condition[[filter$condition]], ' '))  ## subsequent filters
      }
    } else {  # not a nested filter group - process as a single filter
      if (length(filter$rules[[i]]$value) == 0) {  # value is list() when checking for NA
        value <- 0
      } else if (filter$rules[[i]]$type == 'date') {  # treat dates
        if (length(filter$rules[[i]]$value) > 1) {
          value <- lapply(filter$rules[[i]]$value, function(x) paste0('as.Date(\"', x, '\", "%m/%d/%Y")'))  # date range
        } else {
          value <- paste0('as.Date(\"', filter$rules[[i]]$value, '\", "%m/%d/%Y")')  # single date
        }
      } else if (filter$rules[[i]]$type == 'string') {  # enclose strings in quotes
        if (length(filter$rules[[i]]$value) > 1) {
          value <- lapply(filter$rules[[i]]$value, function(x) paste0('\"', x, '\"'))  # list of strings
        } else {
          value <- paste0('\"', filter$rules[[i]]$value, '\"')  # single string
        }
      } else {
        value = filter$rules[[i]]$value
      }
      if (is.null(fs)) {
        fs <- lookup(filter$rules[[i]]$id, filter$rules[[i]]$operator, value)  # first filter
      } else {
        fs <- paste(fs, lookup(filter$rules[[i]]$id, filter$rules[[i]]$operator, value), sep = paste0(' ', condition[[filter$condition]], ' '))  # subsequent filters
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


#' upTrend - analysis helper function
#' @export
upTrend <- function(...) {
  vals <- list(...)
  if (length(vals) < 2) return(TRUE)
  for (i in 2:length(vals)) {
    if (vals[[i-1]] > vals[[i]]) return(FALSE)
  }
  return(TRUE)
}


#' downTrend - analysis helper function
#' @export
downTrend <- function(...) {
  vals <- list(...)
  if (length(vals) < 2) return(TRUE)
  for (i in 2:length(vals)) {
    if (vals[[i-1]] < vals[[i]]) return(FALSE)
  }
  return(TRUE)
}

