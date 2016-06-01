
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
	var images = ['s1', 's5', 's6'];
	var randomSlide1 = images[Math.floor(Math.random() * images.length)];
 	$('#slide1').addClass(randomSlide1);
 	var images2 = ['s2', 's3', 's4'];
 	var randomSlide2 = images2[Math.floor(Math.random() * images.length)];
 	$('#slide2').addClass(randomSlide2);

 	if ($("#generic_file_license").length){
                $("#generic_file_license").change(function() {
                	if ($("#generic_file_license").val()=="I am required to use/link to a publisher's license") {
                                $("#generic_file_rights").val("Enter full text rights");
                                $('label[for="generic_file_rights"]').show();
    				$("#generic_file_rights").show();
                                $("#generic_file_rights").focus();
  			}
  			else {
            $('label[for="generic_file_rights"]').hide();
    				$("#generic_file_rights").hide();
    				$("#generic_file_rights").val("");
  			}
                        
		});
	}
        if ($("#generic_file_rights").length){
                if (document.getElementById('generic_file_rights') == null) { 
                        $('label[for="generic_file_rights"]').hide();
                	$("#generic_file_rights").hide();
                }
                else {
                        if (document.getElementById('generic_file_rights').value == "") {
                                $('label[for="generic_file_rights"]').hide();
                        	$("#generic_file_rights").hide();
                        }
                        else {
                                $('label[for="generic_file_rights"]').show();
				$("#generic_file_rights").show();
                        }
                }
	}
        if ($("#tweets").length){
                var config1 = {
                        "id": '586195044660424704',
                        "domId": 'tweets',
                        "maxTweets": 2,
                        "enableLinks": true
                };
                twitterFetcher.fetch(config1);
        }
        $("#filter").userSearch();
        $("#filter").bind("change", function() {
        	obj = $("#filter").select2("data")
                $("#filter").select2("val", '')
		window.location = "/dashboard/all?f[creator_sim][]="+obj.text;
		return false;
        });

	
	if ($(".browse").length){
		$(".facet_select")
   		.each(function(){ 
      		this.href = this.href.replace('browse', 'catalog');
   		});
   	}

 $('#terms_of_service').on('change',function(e) {
    if ($(this).prop('checked')) {
        $('#step-one').removeClass('progtrckr-todo');
        $('#step-two').removeClass('progtrckr-todo');
        $('#step-two').addClass('progtrckr-current');
        $('#step-one').addClass('progtrckr-done');
    } else {
        $('#step-one').removeClass('progtrckr-done');
        $('#step-two').removeClass('progtrckr-current');
        $('#step-two').addClass('progtrckr-todo');
        $('#step-one').addClass('progtrckr-todo');
    };
});

// Parse URL Queries Method
(function($){
    $.getQuery = function( query ) {
        query = query.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        var expr = "[\\?&]"+query+"=([^&#]*)";
        var regex = new RegExp( expr );
        var results = regex.exec( window.location.href );
        if( results !== null ) {
            return results[1];
            return decodeURIComponent(results[1].replace(/\+/g, " "));
        } else {
            return false;
        }
    };
})(jQuery);

  var closed = $.getQuery('closed');
  // TODO temporarily disabling this for release. We can reenable afterwards
  // once we've locked down some of the bugs that are causing it to show up
  // in unexected places. See issues #765, #770 for details
  //
  // if (($("#documents .progress").length) && (closed == !"yes")) {
  //     $(".lightbox").show(); 
  //     setTimeout('window.location.reload();', 5000);
  // }

  $( ".btn-noccid" ).click(function() {
    $( "#era-login" ).slideToggle( "fast", function() {
    // Animation complete.
  });
});

});
