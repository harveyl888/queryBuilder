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
          jsonString = '{ "id": "' + i.name + '", "label": "' + i.name + '" , "type": "' + i.type + '" }';
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
