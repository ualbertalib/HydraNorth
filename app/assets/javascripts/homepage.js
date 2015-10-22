$(function() {
	create_repository_chart();
});

function create_repository_chart() {
	$.getJSON('/stats.json').done(function(stats) {
		initialize_chart(stats);
	}).fail(function() {
		// hardcoded, out-of-data but reasonable data to use
		// if something goes wrong in fetching the real time stats
		initialize_chart({
			'total_count': '36,675',
			'facets': [
				{indexLabel: "Report", y: 9136},
				{indexLabel: "Image", y: 5416},
				{indexLabel: "Thesis", y: 17276},
				{indexLabel: "Journal Article (Published)", y: 1706},
				{indexLabel: "Other", y: 1839}
			]
		});
	});
}

function initialize_chart(stats) {
	// set the overall item count
	$('span#chart-item-count').text(stats.total_count);

	// build the chart
	var chart = new CanvasJS.Chart("chartContainer",
		{data: [{
	      	indexLabelFontSize: 16,
			indexLabelFontColor: "darkgrey",
			indexLabelPlacement: "outside",
	        type: "doughnut",
	        dataPoints: stats.facets
	    }]}
	);

	chart.render();
}