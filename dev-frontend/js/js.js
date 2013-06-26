// Create the XHR object.
function createCORSRequest(method, url) {
  var xhr = new XMLHttpRequest();
  if ("withCredentials" in xhr) {
    // XHR for Chrome/Firefox/Opera/Safari.
    xhr.open(method, url, true);
  } else if (typeof XDomainRequest != "undefined") {
    // XDomainRequest for IE.
    xhr = new XDomainRequest();
    xhr.open(method, url);
  } else {
    // CORS not supported.
    xhr = null;
  }
  return xhr;
}

function debuggerResult(string, status) {
  $('#debugger-result').removeClass('success error info').addClass(status);
  $('#debugger-result').html(string);
}


$(document).ready(function() {
  $('#debugger').bind('submit', function(e){
    e.preventDefault();

    debuggerResult("Loading ...", "info");

    var form = this;
    var url = $(form.url).val();
    var rtype = $(form.rtype).val();
    var params = $(form.params).val();

    if(!url) {
      debuggerResult("Whoops, empty request URL?");
      return;
    }
    
    var xhr = createCORSRequest(rtype, url);
    
    xhr.onerror = function() {
      debuggerResult('Woops, there was an error making the request.');
    };

    xhr.onload = function() {
      if(xhr.status != 200) {
        window.setTimeout(function(){
          debuggerResult(xhr.statusText + ' (' + xhr.status + '): ' + xhr.responseText, 'error');  
        }, 200);
      } else {
        window.setTimeout(function(){
          debuggerResult(xhr.responseText, 'success');
        }, 200);
      }
      
    };

    xhr.send(params);
  });


});