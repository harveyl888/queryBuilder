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
        opObj.compareGroups = ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'not_between', 'is_na', 'is_not_na', 'equal_', 'not_equal_', 'less_', 'less_or_equal_', 'greater_', 'greater_or_equal_'];


        var filter = [];
        x.data.forEach(function(i) {
          var myFilter = {};
          myFilter.id = i.name;
          myFilter.label = i.name;
          myFilter.type = i.type;
          if (i.hasOwnProperty('input')) {
            if (i.input != 'selectize' && i.input.substring(0, 5) != 'group' && i.input != 'function_0') {
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
          if (i.hasOwnProperty('input')) {
                      if (i.input == 'function_0') {
            myFilter.plugin = 'selectize';
            selectizeOptions = [];
            if (i.hasOwnProperty('values')) {
              i.values.forEach(function(x) { selectizeOptions.push({ id: x })});
            } else {
            x.colnames.forEach(function(x) { selectizeOptions.push({ id: x })});
            }
            myFilter.plugin_config = { "valueField" : "id", "labelField" : "id", "maxItems" : null, "create" : false, "plugins" : [ 'remove_button', 'drag_drop' ], "options" : selectizeOptions};
            myFilter.valueGetter = function(rule) { return rule.$el.find('.selectized').selectize()[0].selectize.items; };
          } else if (i.input.substring(0, 5) == 'group') {
            var optionValues2 = '';
            x.data.forEach(function(j) {

              console.log(j.input);

              if (j.input == i.input) {
                optionValues2 += '<option value="'+ j.name + '">' + j.name + '</option>';
              }
            });
            myFilter.validation = { "callback" : function(value, rule) { return(true); } };
            myFilter.input = function(rule, name) {
              $operator_container = rule.$el.find('.rule-operator-container');
              var myOptGroup = rule.$el.find('.rule-operator-container .form-control option:selected').closest('optgroup').attr('label');
              var show_select = (myOptGroup == 'Group');
              var show_text = !show_select;
              var htmlOut =  '<select name = \"' + name + '_1\" class = \"form-control value-select\"' + (show_text ? ' style = \"display: none;\"' : '') + ' onchange=\"data_from_select(this)\"' + '>';
              htmlOut += optionValues2;
              htmlOut += '</select>';
              htmlOut += '<input name = \"' + name + '_2\" class = \"form-control value-text\" type = \"text\"' + (show_select ? ' style=\"display: none;\"' : '') + 'onchange=\"data_from_text(this)\" onkeyup=\"data_from_text(this)\"' + '></input>';
              return htmlOut;
            };
            myFilter.valueGetter = function(rule) {
              return rule.$el.find('.rule-value-container').attr('data-value');

            };

          } else if (i.input == 'select' || i.input == 'radio') {
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
         }
        } else if (i.type == 'date') {
           myFilter.plugin = 'datepicker';
           myFilter.plugin_config = { "format" : i.mask, "todayBtn" : "linked", "todayHighlight" : true, "autoclose" : true };
          }

          // Add operators to filter
          if (i.input == 'selectize') {
            myFilter.operators = ['in', 'not_in'];
          } else if (i.input == 'function_0') {
            myFilter.operators = ['up', 'down'];
          } else if (i.hasOwnProperty('input')) {
            if (i.input.substring(0, 5) == 'group') {
              myFilter.operators = opObj.compareGroups;
            }
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
        myOperators.forEach(function(x) { operator.push({ type : x, optgroup : 'Scalar'}) });
        operator.push({ type: "is_not_na", optgroup: "NA values", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] });
        operator.push({ type: "is_na", optgroup: "NA values", "nb_inputs": "0", "apply_to": ["number", "string", "datetime", "boolean"] });
        operator.push({ type: "up", optgroup: "Trend Analysis", "nb_inputs": "1", "apply_to": ["string"] });
        operator.push({ type: "down", optgroup: "Trend Analysis", "nb_inputs": "1", "apply_to": ["string"] });

        // Add additional operators for group comparison
        var myOperatorsGroups = ['equal_', 'not_equal_', 'less_', 'less_or_equal_', 'greater_', 'greater_or_equal_'];
        myOperatorsGroups.forEach(function(x) { operator.push({ type : x, optgroup : 'Group', nb_inputs: 1, apply_to: ["number"] }) });

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

        // Add group functionality
        // Change input to select or text based on operator

        $(el).on('afterUpdateRuleOperator.queryBuilder', function(e, rule) {
            // If we can have GroupOps then we need to determine the type of operator and display the correct input
          if (rule.$el.find('.rule-operator-container .form-control optgroup[label=Group]').html() !== null) {
            var myOptGroup = rule.$el.find('.rule-operator-container .form-control option:selected').closest('optgroup').attr('label');

            if (myOptGroup == 'Group') {
              rule.$el.find('.rule-value-container .value-select').css("display", "inline");
              rule.$el.find('.rule-value-container .value-text').css("display", "none");
            } else {
              rule.$el.find('.rule-value-container .value-select').css("display", "none");
              rule.$el.find('.rule-value-container .value-text').css("display", "inline");
            }
          }
        });

        data_from_select = function(id) {
          $(id).parent().attr('data-value', $(id).find(":selected").val());
        };

        data_from_text = function(id) {
          $(id).parent().attr('data-value', $(id).val());
        };


        // Add jquery chosen functionality to all select boxes
        if(x.settings.chosen) {
          $(el).on('afterCreateRuleInput.queryBuilder', function(e, rule) {
            $(el).find("select").addClass("chosen-select");
            $(el).find("value-select").addClass("chosen-select");
//            $(el).find(".rule-filter-container .form-control").addClass("chosen-select");
            $(".chosen-select").chosen();
          });
        }

        // for debugging
        window.filterout = filter;
        window.operatorout = operator;

        // build the query
        $(el).queryBuilder({
          filters: filter,
          default_condition: x.settings.default_condition,
          allow_empty: x.settings.allow_empty,
          display_errors: x.settings.display_errors,
          display_empty_filter: x.settings.display_empty_filter,
          operators: operator
        });

        $(el).css("overflow", "auto");

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
