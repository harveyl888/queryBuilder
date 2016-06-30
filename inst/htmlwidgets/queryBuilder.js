HTMLWidgets.widget({

  name: 'queryBuilder',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        window.xx = x;



        // Generate json strings from x.data
        var jsonString;
        var filter = [];
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

/*
          switch(i.type) {
            case "string":
              jsonString = '{ "id": "' + i.name + '", "label": "' + i.name + '", "type": "' + i.type + '", "input": "text" }';
              break;
            case "integer":
              jsonString = '{ "id": "' + i.name + '", "label": "' + i.name + '", "type": "' + i.type + '", "input": "text"';
              var myProps = ["min", "max", "step"];
              if (i.hasOwnProperty("min") | i.hasOwnProperty("max") | i.hasOwnProperty("step")) {
                jsonString += ', "validation": {';
                var addjson = [];
                for (var j in myProps) {
                  if (i.hasOwnProperty(myProps[j])) { addjson.push('"' + myProps[j] + '": ' + i[myProps[j]]); }
                }
                jsonString += addjson.join() + '}';
              }
              jsonString += '}';
              break;
            case "select":
              jsonString = '{ "id": "' + i.name + '", "label": "' + i.name + '", "type": "' + i.type + '", "input": "select"';

              if (i.hasOwnProperty("values")) {
                jsonString += ', "values": {';
                var addjsonSelect = [];

                for (var k = 0; k < i.values.length; k++) {
                  addjsonSelect.push('"' + i.values[k] + '": "' + i.values[k] + '"');
                }
                jsonString += addjsonSelect.join(", ") + '}';
              }
              jsonString += '}';
              break;
          }  */
          filter.push(jsonString);
        });
        var jsonFilter = JSON.parse("[" + filter.join() + "]");

        $(el).queryBuilder({
          filters: jsonFilter
        });

        // don't display errors
        $(el).on('validationError.queryBuilder', function(e, rule, error, value) {
          e.preventDefault();
        });

        // return shiny variable containing filters
        $(el).on('afterUpdateRuleValue.queryBuilder', function(e, rule, error, value) {
          Shiny.onInputChange(el.id + '_out', $(el).queryBuilder('getRules'));
        });

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
