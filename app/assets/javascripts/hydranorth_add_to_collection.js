  var remove_button = $("<button type=\"button\" class=\"btn btn-danger remove_collection_group\"><i class=\"icon-white glyphicon-minus\"></i><span>Remove the following community/collection group</span></button><br>");
  $(document).on("click", ".add_collection_group", function(){
  current = $('div[class^="community-group"]').last()
  addNewGroup(current);
  });
  $(document).on("click", ".remove_collection_group", function(){
  var current = $(this).parent()
  removeCurrentGroup(current);
  });
  function addNewGroup(current){
    current_class= current.attr('class')
    index = current_class.split('-')[2]
    newIndex = "community-group-" + (parseInt(index) +1).toString();
    newGroup = current.clone().removeClass(current_class).addClass(newIndex);
    newCommunity = newGroup.children('select#generic_file_belongsToCommunity');
    newCommunity.removeClass(current_class).addClass(newIndex);
    if (index == 1) {
      newCommunity.val('').removeProp('required');
      newCommunityLabel = newGroup.children("label[for='generic_file_belongsToCommunity']")
      newCommunityLabel.removeClass('required');
      newCommunityLabel.children('abbr[title="required"]').remove();
    }
    newCollection = newGroup.children('select#generic_file_hasCollectionId');
    newCollection.removeClass(current_class).addClass(newIndex);
    newCommunity.first().focus();
    newGroup.prepend(remove_button);
    newGroup.insertAfter(current);
  }
  function removeCurrentGroup(current){
    current.remove()
  }
