HTMLWidgets.widget({

  name: 'queryBuilder',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {

        // for debugging
        window.widgetInput = x;

        var opObj = {};
        opObj.text = '"equal", "not_equal", "begins_with", "not_begins_with", "ends_with", "not_ends_with", "contains", "not_contains", "is_na", "is_not_na"';
        opObj.numeric = '"equal", "not_equal", "less", "less_or_equal", "greater", "greater_or_equal", "between", "not_between", "is_na", "is_not_na"';


        // Generate json strings from x.data
        var jsonString;  // string to store json-formatted filter
        var filter = [];  // array to store all the filters
        x.data.forEach(function(i) {
          jsonString = '{ "id": "' + i.name + '", "label": "' + i.name + '", "type": "' + i.type + '"';
          if (i.hasOwnProperty("input")) {
            if (i.input != 'selectize') {
              jsonString += ', "input": "' + i.input + '"';
            }
          }
          if (i.type == 'integer' || i.type == 'double') {
            var myProps = ["min", "max", "step"];
            if (i.hasOwnProperty("min") || i.hasOwnProperty("max") || i.hasOwnProperty("step")) {
              jsonString += ', "validation": {';
              var addjsonNum = [];
              for (var j in myProps) {
                if (i.hasOwnProperty(myProps[j])) { addjsonNum.push('"' + myProps[j] + '": ' + i[myProps[j]]); }
              }
              jsonString += addjsonNum.join() + '}';
            }
          }
          if (i.input == 'select') {
            if (i.hasOwnProperty("values")) {
              jsonString += ', "values": [';
              var addjsonSelect = [];

              for (var k = 0; k < i.values.length; k++) {
                addjsonSelect.push('"' + i.values[k] + '"');
              }
              jsonString += addjsonSelect.join(", ") + ']';
            }
          } else if (i.input == 'selectize') {
            if (i.hasOwnProperty("values")) {
              jsonString += ', "plugin": "selectize", "plugin_config": { ';
              jsonString += '"valueField": "id", "labelField": "id", "maxItems": "null", "create": "false", ';
              jsonString += '"options": [';
              var addjsonSelectize = [];
              for (var k1 = 0; k1 < i.values.length; k1++) {
                addjsonSelectize.push('{"id": "' + i.values[k1] + '"}');
              }
              jsonString += addjsonSelectize.join(", ") + '] }';
            }
          }


          if (i.input == 'selectize') {
            jsonString += ', "operators": [ "in", "not_in" ]';
          } else if (i.input == 'select') {
            jsonString += ', "operators": [ "equal", "not_equal", "is_na", "is_not_na" ]';
          } else if (i.hasOwnProperty("operators")) {
            var addjsonOperators = [];
            for (var op in i.operators) {
              addjsonOperators.push('"' + i.operators[op] + '"');
            }
            jsonString += ', "operators": [' + addjsonOperators.join(", ") + ']';
          } else if (i.type == 'integer' || i.type == 'double') {
            jsonString += ', "operators": [' + opObj.numeric + ']';
          } else if (i.type == 'text') {
            jsonString += ', "operators": [' + opObj.text + ']';
          }


          jsonString += '}';
          filter.push(jsonString);  // add this filter to the filter array
        });
        var jsonFilter = JSON.parse("[" + filter.join() + "]");  // parse all the filters
        Shiny.onInputChange(el.id + '_filters', '[' + filter.join() + ']');

        // for debugging
        window.jsonFilter = jsonFilter;

        var myOperators = ["equal", "not_equal", "less", "less_or_equal", "greater", "greater_or_equal", "between", "not_between", "begins_with", "not_begins_with", "ends_with", "not_ends_with", "contains", "not_contains", "in", "not_in"];
        var operator = [];
        for (var j in myOperators) {
          operator.push('{ "type": "' + myOperators[j] + '" }');
        }
        operator.push('{ "type": "is_not_na", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] }');
                operator.push('{ "type": "is_na", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] }');

        var jsonOperators =  JSON.parse("[" + operator.join() + "]");  // parse all the operators

        // initialize validate status to false
        Shiny.onInputChange(el.id + '_validate', false);

        // add a fix for selectize
        $(el).on('afterCreateRuleInput.queryBuilder', function(e, rule) {
                                                        if (rule.filter.plugin == 'selectize') {
                                                        rule.$el.find('.rule-value-container').css('min-width', '200px')
                                                        .find('.selectize-control').removeClass('form-control');
                                                      }
                                                    });

        // build the query
        $(el).queryBuilder({
          filters: jsonFilter,
          operators: jsonOperators
        });

        // don't display errors
        $(el).on('validationError.queryBuilder', function(e, rule, error, value) {
          e.preventDefault();
        });

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
