HTMLWidgets.widget({

  name: 'queryBuilder',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // for debugging
        window.widgetInput = x;

        var opObj = {};
        opObj.text = '"equal", "not_equal"';
        opObj.numeric = '"equal", "not_equal", "less", "less_or_equal", "greater", "greater_or_equal", "between", "not_between"';


        // Generate json strings from x.data
        var jsonString;  // string to store json-formatted filter
        var filter = [];  // array to store all the filters
        x.data.forEach(function(i) {
          jsonString = '{ "id": "' + i.name + '", "label": "' + i.name + '", "type": "' + i.type + '"';
          if (i.hasOwnProperty("input")) {
            jsonString += ', "input": "' + i.input + '"';
          }
          if (i.type == 'integer' | i.type == 'double') {
            var myProps = ["min", "max", "step"];
            if (i.hasOwnProperty("min") | i.hasOwnProperty("max") | i.hasOwnProperty("step")) {
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
              jsonString += ', "values": {';
              var addjsonSelect = [];

              for (var k = 0; k < i.values.length; k++) {
                addjsonSelect.push('"' + i.values[k] + '": "' + i.values[k] + '"');
              }
              jsonString += addjsonSelect.join(", ") + '}';
            }
          }

          if (i.hasOwnProperty("operators")) {
            var addjsonOperators = [];
            for (var op in i.operators) {
              addjsonOperators.push('"' + i.operators[op] + '"');
            }
            jsonString += ', "operators": [' + addjsonOperators.join(", ") + ']';
          } else if (i.type == 'integer' | i.type == 'double') {
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

        var myOperators = ["equal", "not_equal"];
        var operator = [];
        for (var j in myOperators) {
          operator.push('{ "type": "' + myOperators[j] + '" }');
        }
        operator.push('{ "type": "is_not_na", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] }');
                operator.push('{ "type": "is_na", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] }');

        var jsonOperators =  JSON.parse("[" + operator.join() + "]");  // parse all the operators

        // initialize validate status to false
        Shiny.onInputChange(el.id + '_validate', false);

        // build the query
        $(el).queryBuilder({
          filters: jsonFilter,
          operators: jsonOperators,
          lang_code: '"en"'
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
