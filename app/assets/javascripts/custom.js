
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
		},		
		function() {
			$(this).find(".show-info").fadeOut(250);
	});
	var images = ['slide1.jpg', 'slide5.jpg', 'slide6.jpg', 'slide8.jpg'];
 	$('#slide1').css({'background-image': 'url(assets/' + images[Math.floor(Math.random() * images.length)] + ')'});
 	var images2 = ['slide2.jpg', 'slide3.jpg', 'slide4.jpg', 'slide7.jpg'];
 	$('#slide2').css({'background-image': 'url(assets/' + images2[Math.floor(Math.random() * images.length)] + ')'});

 	if ($("#tweets").length){
	 	var config1 = {
	  		"id": '586195044660424704',
	  		"domId": 'tweets',
	  		"maxTweets": 1,
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
