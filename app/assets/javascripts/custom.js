
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
});