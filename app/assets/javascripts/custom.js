
$(document).ready(function(){
	$(".slides").hoverIntent(
		function() {
			$(this).fadeTo(250, 1);
			$(this).find(".more-info").animate({
				height:"60px", paddingTop:"20px"}, 400);
		},		
		function() {
			$(this).fadeTo(250, 0.8);
			$(this).find(".more-info").animate({
				height:"40px", paddingTop:"10px"}, 400);
	});
	$(".show-image").hoverIntent(
		function() {
			$(this).find(".show-info").fadeIn(250);
			$(this).find("span").hide();
		},		
		function() {
			$(this).find(".show-info").fadeOut(250);
			$(this).find("span").show();
	});
	var images = ['s1', 's5', 's6', 's8'];
	var randomSlide1 = images[Math.floor(Math.random() * images.length)];
 	$('#slide1').addClass(randomSlide1);
 	var images2 = ['s2', 's3', 's4', 's7'];
 	var randomSlide2 = images2[Math.floor(Math.random() * images.length)];
 	$('#slide2').addClass(randomSlide2);

 	if ($("#tweets").length){
	 	var config1 = {
	  		"id": '586195044660424704',
	  		"domId": 'tweets',
	  		"maxTweets": 2,
	  		"enableLinks": true
		};
		twitterFetcher.fetch(config1);
	}
	if ($("#chartContainer").length){
	var chart = new CanvasJS.Chart("chartContainer",
    {
      data: [
      {
      	indexLabelFontSize: 16,
		indexLabelFontColor: "darkgrey",
		indexLabelPlacement: "outside",
       type: "doughnut",
       dataPoints: [
       {  y: 17356, indexLabel: "Theses" },
       {  y: 5593, indexLabel: "Research Materials" },
       {  y: 9280, indexLabel: "Reports" },
       {  y: 1611, indexLabel: "Journal Articles" },
       {  y: 856, indexLabel: "Other" }
       ]
     }
     ]
   });

    chart.render();
}
});
