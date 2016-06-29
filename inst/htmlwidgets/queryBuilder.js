HTMLWidgets.widget({

  name: 'queryBuilder',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

        window.xx = x;

//        alert(x.data[0].name)

        var filter1 = JSON.parse('{ "id": "name", "label": "Name", "type": "string" }');


        $(el).queryBuilder({

          filters:[ filter1 ]

 /*         filters:[{
            id: 'name',
            label: 'Name',
            type: 'string'
          }]*/
        });

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
