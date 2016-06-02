$(document).ready(function(){
        if ($("#descriptions_display").length){
                var checkbox = document.getElementById('collection_is_community');
                var logo_div = document.getElementById('logo');
                var logo = document.getElementById('collection_logo');

                if (checkbox.checked) {
                  logo_div.style['display'] = 'block';
                }

                checkbox.onchange = function() {
                if(this.checked) {
                  logo_div.style['display'] = 'block';
                } else {
                  logo_div.style['display'] = 'none';
                }};

                logo.onchange = function() {
                  validateFiles(logo);
                };

                function validateFiles(inputFile) {
                  var maxExceededMessage = "This file exceeds the maximum allowed file size (20 KB)";
                  var extErrorMessage = "Only image file with extension: .jpg, .jpeg, .gif or .png is allowed";
                  var allowedExtension = ["jpg", "jpeg", "gif", "png"];
  
                  var extName;
                  var file = inputFile.files[0];
                  var maxFileSize = $(inputFile).data('max-file-size');
                  var sizeExceeded = false;
                  var extError = false;
  
                  if (file.size && maxFileSize && file.size > parseInt(maxFileSize)) {sizeExceeded=true;};
                  extName = file.name.split('.').pop();
                  if ($.inArray(extName, allowedExtension) == -1) {extError=true;};

                  if (sizeExceeded) {
                    window.alert(maxExceededMessage);
                    $(inputFile).val('');
                  };
  
                  if (extError) {
                    window.alert(extErrorMessage);
                    $(inputFile).val('');
                  };
               }
        }
});
