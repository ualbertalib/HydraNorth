
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

 	var config1 = {
  		"id": '586195044660424704',
  		"domId": 'tweets',
  		"maxTweets": 2,
  		"enableLinks": true
	};
	twitterFetcher.fetch(config1);
	
	var doughnutData = [
				{
					value: 1,
					label: "One"
				},
				{
					value: 2,
					label: "Two"
				},
				{
					value: 3,
					label: "Three"
				},
				{
					value: 4,
					label: "Four"
				},
				{
					value: 5,
					label: "Five"
				}

			];

			window.onload = function(){
				var ctx = document.getElementById("chart-area").getContext("2d");
				window.myDoughnut = new Chart(ctx).Doughnut(doughnutData, {responsive : true});
			};



});
