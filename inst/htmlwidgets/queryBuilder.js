HTMLWidgets.widget({

  name: 'queryBuilder',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        window.xx = x;

//        alert(x.data[0].name)

//        var filter1 = JSON.parse('{ "id": "name", "label": "Name", "type": "string" }');


        // Generate json strings from x.data


        var jsonString;
        var filter = [];
        x.data.forEach(function(i) {

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
          }
          filter.push(jsonString);
        });
        var jsonFilter = JSON.parse("[" + filter.join() + "]");

        $(el).queryBuilder({
          filters: jsonFilter
        });

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
