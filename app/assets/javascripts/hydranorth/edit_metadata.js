Blacklight.onLoad(function() {
  function get_autocomplete_opts(field) {
    var autocomplete_opts = {
      minLength: 2,
      source: function( request, response ) {
        $.getJSON( "/authorities/generic_files/" + field, {
          q: request.term
        }, response );
      },
      focus: function() {
        // prevent value inserted on focus
        return false;
      },
      complete: function(event) {
        $('.ui-autocomplete-loading').removeClass("ui-autocomplete-loading");
      }
    };
    return autocomplete_opts;
  }

  var autocomplete_vocab = new Object();
  autocomplete_vocab.url_var = ['spatial'];   // the url variable to pass to determine the vocab to attach to
  autocomplete_vocab.field_name = new Array(); // the form name to attach the event for autocomplete

  // loop over the autocomplete fields and attach the
  // events for autocomplete and create other array values for autocomplete
  for (var i=0; i < autocomplete_vocab.url_var.length; i++) {
    autocomplete_vocab.field_name.push('generic_file_' + autocomplete_vocab.url_var[i]);
    // autocompletes
    $("#" + autocomplete_vocab.field_name[i])
        // don't navigate away from the field on tab when selecting an item
        .bind( "keydown", function( event ) {
            if ( event.keyCode === $.ui.keyCode.TAB &&
                    $( this ).data( "autocomplete" ).menu.active ) {
                event.preventDefault();
            }
        })
        .autocomplete( get_autocomplete_opts(autocomplete_vocab.url_var[i]) );
  }


  // attach an auto complete based on the field
  function setup_autocomplete(e, cloneElem) {
    var $cloneElem = $(cloneElem);
    // FIXME this code (comparing the id) depends on a bug. Each input has an id and the id is
    // duplicated when you press the plus button. This is not valid html.
    if ( (index = $.inArray($cloneElem.attr("id"), autocomplete_vocab.field_name)) != -1 ) {
      $cloneElem.autocomplete(get_autocomplete_opts(autocomplete_vocab.url_var[index]));
    }
  }

  $('.multi_value.form-group').manage_fields({add: setup_autocomplete});
});
