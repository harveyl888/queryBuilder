# queryBuilder
An htmlwidget for jQuery QueryBuilder

jQuery QueryBuilder is a jQuery plugin offering an simple interface to create complex queries written by @mistic100.  The javascript library can be found at https://github.com/mistic100/jQuery-QueryBuilder with documentation and examples at http://querybuilder.js.org/.

This htmlwidget works in shiny apps and uses jQuery QueryBuilder to build a query using data frame columns and dplyr to filter the data frame from the query.


## Install
```r
library(devtools)
devtools::install_github("harveyl888/queryBuilder")
```

## Usage
Minimally, queryBuilder can be used with a data frame and list of filters as follows
```r
queryBuilder(data, filters)
```
queryBuilder can take a number of arguments:
-   `data`: A data frame containing the data to be filtered.
-   `filters`: A list of lists containing filter information (see below).
-   `autoassign`: Boolean.  If true then the filter information is automatically assigned according to column class and the `filter` argument is ignored (default = false).
-   `default_condition`: Default condition for rules (can be 'AND' or 'OR', default = 'AND').
-   `allow_empty`: Boolean.  If set to true then no validation error is thrown when the builder is entirely empty (default = false).
-   `display_errors`: Boolean.  If set to true then an icon and tooltip explaining the error will be displayed (default = true).
-   `display_empty_filter`: Boolean.  If true then an empty option will be included for each rule.  If false then the first filter will be selected when creating the rule (default = true).

## Filters
jQuery QueryBuilder can create powerful queries from a series of inputs.  The `filters` option of this widget can be used to specify specific columns of a data frame and determine how they behave in jQuery QueryBuilder.  It is constructed as a list of lists containing a number of named attributes.  
For example, using the `mtcars` data, filters for mpg and cyl can be constructed as follows:
```r
filters = list(list(name = 'mpg', type = 'double', min = min(mtcars$mpg), max = max(mtcars$mpg), step = 0.1),
               list(name = 'cyl', type = 'double'))
```
Here both mpg and cyl are defined with type double.  In addition, mpg has an allowable range between its minimum and maximum values




To be done: complete README.md
