function update_collections() {
	// TODO I'm not really clear on the necessity of grovelling
	// through any matching item's class string to find an "index"
	// here. A custom data attribute would likely be a better choice.
	// I don't want to delay the bugfix to clean this up, though -- MB
	if (!($('.community-select').attr('class'))) return;

	currentClass = $('.community-select').attr('class').split(' ');

	var index;

	$.each(currentClass, function(i, v) {

		if (v.match(/community-group/)) {
			index = v
		}
	});

	$.ajax({
		url: 'update_collections',
		type: 'GET',
		dataType: 'script',
		data: {
			community_id: $("option:selected", '.community-select').val(),
			index: index
		},
		complete: function() {},
		success: function(data, textStatus, xhr) {},
		error: function() {}
	});
}


$(function() {
	$('#generic_file_belongsToCommunity').change(function() {
		// Reload collections when the community selection is changed.
		update_collections();
	});
});
