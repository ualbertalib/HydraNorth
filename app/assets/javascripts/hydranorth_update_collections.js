$(document).on("change", '.community-select', function(){ 
          currentClass = $(this).attr('class').split(' ')
          var index
          $.each ( currentClass, function(i, v) {
            if (v.match(/community-group/)) { index = v}
          });
          $.ajax({
            url: 'update_collections',
            type: 'GET',
            dataType: 'script',
            data:  {
              community_id: $("option:selected", this).val(),
              index: index
            },
            complete: function() {}, 
            success: function(data, textStatus, xhr) {
            },
            error: function() {}
           });

});
