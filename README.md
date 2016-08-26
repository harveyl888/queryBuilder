# queryBuilder
An htmlwidget for jQuery QueryBuilder

jQuery QueryBuilder is a jQuery plugin offering an simple interface to create complex queries written by [@mistic100](https://github.com/mistic100).  The javascript library can be found at https://github.com/mistic100/jQuery-QueryBuilder with documentation and examples at http://querybuilder.js.org/.

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
Here both mpg and cyl are defined with type double.  In addition, mpg has an allowable range between its minimum and maximum values.

Filter types include integer, double, string, date and boolean.  In addition, select, radio and the selectize plugin are recognized.

If autoassign is set to true then all the columns from the data frame will be used as potential filters and they will be assigned according to the column class as follows:
-   `numeric`: filter type = double
-   `integer`: filter type = integer
-   `character`: filter type = string
-   `factor`: filter type = string, input = selectize
-   `Date`: filter type = date
-   `logical`: filter type = boolean, input = radio

## Shiny
The queryBuilder widget returns a number of variables back to Shiny apps, each of which are prefixed by the element id and outlined below for an element created using `queryBuilderOutput('querybuilder')`:
-   `querybuilder_filters`: stringified JSON representation of input filters. 
-   `querybuilder_out`: result of jQuery QueryBuilder's getRules method.  This output is used to subsequently filter the data frame.
-   `querybuilder_validate`: result of jQuery QueryBuilder's validate method.


In addition to constructing the htmlwidget, an additional function called filterTable is defined:
`filterTable(input$querybuilder_out, data, 'table')` returns a filtered data frame for element `querybuilder` on data frame `data`.
`filterTable(input$querybuilder_out, data, 'text')` returns the input to dplyr filter_ for element `querybuilder` on data frame `data`. 

### Shiny Example
A Shiny example can be found under inst/examples/example01.  In this case part of the mtcars data are used with some additonal columns:
-   mpg: mtcars mpg column with allowable range between the minimum and maximum values.
-   disp: mtcars disp column with minimum value of 60.
-   gear: mtcars gear column with select input (only a single value may be selected).
-   name: character column taken from rownames.
-   nameFactor: name column defined as a factor to demonstrate selectize.
-   date: random date generated between 01-Jan-2016 and 20-Jan-2016.
-   logical: boolean value.
-   carb: selectize (can filter on multiple values).

This example can also be found at http://162.243.57.47:3838/home/harvey/queryBuilder/

## Experimental Features
jQuery queryBuilder is a powerful tool and there are some features which are somewhat *experimental*.
### Additional Functions
A trending function has been added.  This will filter based on a series of values that increase or decrease.  The filter takes the form of
```r
list(name = 'Trend', type = 'string', input = 'function_0')
```
This instructs the builder to create a rule with the desired operators and a selectize, sortable output to hold the values.
### Group Comparison
If filters are added with an input that starts with `group` then they'll be treated in two different ways depending on the operator.  If the operator belongs to an optgroup called `Group` then the value can be chosen from a list of other inputs from the same group.  This allows for group comparison such as `Group_1 > Group_2`.  If the operator belongs to a different optgroup then the value is treated as a scalar such as `Group_1 > 12`.  This allows for complex rules to be built with minimal setup.
### Example
An example of each of these features can be found under inst/examples/example02.
