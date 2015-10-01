jQuery(function($){
    $(".add_collection_group").click(function() {
        last_group = $(".community-group:last");
        addNewGroup(last_group);
      });
      function addNewGroup(last_group){
        last_id = last_group.attr('id');
        index = last_id.split('-')[2]
        new_id = "community-group-" + (parseInt(index) +1).toString();
        newGroup = last_group.clone().removeAttr("id").attr("id", new_id);
        newCommunity = newGroup.children('select#generic_file_belongsToCommunity');
        newCommunity.removeClass(last_id).addClass(new_id);
        if (index == 1){
          newGroup.append( $("<button type='button' class='btn btn-danger remove_collection_group'><i class='icon-white glyphicon-minus'></i><span> Remove this Community/Collection group</span></button>") )
          newCommunity.val('').removeProp('required');
          newCommunityLabel = newGroup.children("label[for='generic_file_belongsToCommunity']")
          newCommunityLabel.removeClass('required');
          newCommunityLabel.children('abbr[title="required"]').remove();
        }
        newCollection = newGroup.children('select#generic_file_hasCollectionId');
        newCollection.removeClass(last_id).addClass(new_id);
        newCommunity.first().focus();
        newGroup.appendTo("#additional");
    }
    $("body").on('click',".remove_collection_group", function() {
        $(this).closest(".community-group").remove();
    });
});
