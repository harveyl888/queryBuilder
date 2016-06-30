HTMLWidgets.widget({

  name: 'queryBuilder',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        // for debugging
        window.widgetInput = x;


        // Generate json strings from x.data
        var jsonString;  // string to store json-formatted filter
        var filter = [];  // array to store all the filters
        x.data.forEach(function(i) {
          jsonString = '{ "id": "' + i.name + '", "label": "' + i.name + '", "type": "' + i.type + '"';
          if (i.hasOwnProperty("input")) {
            jsonString += ', "input": "' + i.input + '"';
          }
          if (i.type == 'integer') {
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
          jsonString += '}';
          filter.push(jsonString);  // add this filter to the filter array
        });
        var jsonFilter = JSON.parse("[" + filter.join() + "]");  // parse all the filters

        // for debugging
        window.jsonFilter = jsonFilter;

        // initialize validate status to false
        Shiny.onInputChange(el.id + '_validate', false);

        // build the query
        $(el).queryBuilder({
          filters: jsonFilter
        });

        // don't display errors
        $(el).on('validationError.queryBuilder', function(e, rule, error, value) {
          e.preventDefault();
        });

        // return shiny variables
        $(el).on('afterUpdateRuleValue.queryBuilder', function(e, rule, error, value) {
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
