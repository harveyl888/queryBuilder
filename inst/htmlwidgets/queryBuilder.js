HTMLWidgets.widget({

  name: 'queryBuilder',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {

        // for debugging
        window.widgetInput = x;

        var opObj = {};
        opObj.text = ['equal', 'not_equal', 'begins_with', 'not_begins_with', 'ends_with', 'not_ends_with', 'contains', 'not_contains', 'is_na', 'is_not_na'];
        opObj.numeric = ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'not_between', 'is_na', 'is_not_na'];


        var filter = [];
        x.data.forEach(function(i) {
          var myFilter = {};
          myFilter.id = i.name;
          myFilter.label = i.name;
          myFilter.type = i.type;
          if (i.hasOwnProperty('input')) {
            if (i.input != 'selectize') {
              myFilter.input = i.input;
            }
          }
          if (i.type == 'integer' || i.type == 'double') {
            var myProps = ['min', 'max', 'step'];
            if (i.hasOwnProperty('min') || i.hasOwnProperty('max') || i.hasOwnProperty('step')) {
              var filterValidation = {};
              for (var j in myProps) {
                if (i.hasOwnProperty(myProps[j])) { filterValidation[myProps[j]] = i[myProps[j]]; }
              }
              myFilter.validation = filterValidation;
            }
          }
          if (i.input == 'select' || i.input == 'radio') {
            if (i.hasOwnProperty('values')) {
              var filterValues = [];
              for (var k = 0; k < i.values.length; k++) {
                filterValues.push(i.values[k]);
              }
              myFilter.values = filterValues;
            }
         } else if (i.input == 'selectize') {
            if (i.hasOwnProperty('values')) {
              myFilter.plugin = 'selectize';
              selectizeOptions = [];
              i.values.forEach(function(x) { selectizeOptions.push({ id: x })});
              myFilter.plugin_config = { "valueField" : "id", "labelField" : "id", "maxItems" : null, "create" : false, "options" : selectizeOptions };
              myFilter.valueGetter = function(rule) { return rule.$el.find('.selectized').selectize()[0].selectize.items; };
            }
         } else if (i.type == 'date') {
           myFilter.plugin = 'datepicker';
           myFilter.plugin_config = { "format" : "yyyy/mm/dd", "todayBtn" : "linked", "todayHighlight" : true, "autoclose" : true };
          }

          // Add operators to filter
          if (i.input == 'selectize') {
            myFilter.operators = ['in', 'not_in'];
          } else if (i.input == 'select' || i.input == 'radio') {
            myFilter.operators = ['equal', 'not_equal', 'is_na', 'is_not_na'];
          } else if (i.hasOwnProperty('operators')) {
            myFilter.operators = i.operators;
          } else if (i.type == 'integer' || i.type == 'double' || i.type == 'date') {
            myFilter.operators = opObj.numeric;
          } else if (i.type == 'text') {
            myFilter.operators = opObj.text;
          }
          filter.push(myFilter);
        });

        // for debugging
        window.jsonFilter = filter;

        // Add global operators list
        var myOperators = ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'not_between', 'begins_with', 'not_begins_with', 'ends_with', 'not_ends_with', 'contains', 'not_contains', 'in', 'not_in'];
        var operator = [];
        myOperators.forEach(function(x) { operator.push({ type : x}) });
        operator.push({ type: "is_not_na", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] });
        operator.push({ type: "is_na", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] });

        // return filter as stringified JSON
        Shiny.onInputChange(el.id + '_filters', JSON.stringify(filter));

        // initialize validate status to false
        Shiny.onInputChange(el.id + '_validate', false);

        // add a fix for selectize
        $(el).on('afterCreateRuleInput.queryBuilder', function(e, rule) {
                                                        if (rule.filter.plugin == 'selectize') {
                                                        rule.$el.find('.rule-value-container').css('min-width', '200px')
                                                        .find('.selectize-control').removeClass('form-control');
                                                      }
                                                    });

        // for debugging
        window.filterout = filter;
        window.operatorout = operator;

        // build the query
        $(el).queryBuilder({
          filters: filter,
          operators: operator
        });


        // don't display errors
 //       $(el).on('validationError.queryBuilder', function(e, rule, error, value) {
//          e.preventDefault();
//        });

        // return shiny variables on events
        $(el).on('afterDeleteGroup.queryBuilder afterDeleteRule.queryBuilder afterUpdateRuleValue.queryBuilder afterUpdateRuleFilter.queryBuilder afterUpdateRuleOperator.queryBuilder  afterUpdateGroupCondition.queryBuilder', function(e, rule, error, value) {
          Shiny.onInputChange(el.id + '_out', $(el).queryBuilder('getRules'));
          Shiny.onInputChange(el.id + '_validate', $(el).queryBuilder('validate'));
        });

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
