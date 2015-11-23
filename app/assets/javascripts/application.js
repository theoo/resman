//
//= require prototype
//= require effects
//= require controls
//= require dragdrop
//= require_self
//= require builder
//= require slider
//= require rest_in_place
// require scriptaculous
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// set focus on first form element
window.onload=function(){
  var myform = document.forms[0];
  if (myform){
	  Form.focusFirstElement(myform);	
  }
}


// fade out flash after 5 secs
document.observe("dom:loaded", function() {
  setTimeout(hideFlashMessages, 5000);
});

function hideFlashMessages() {
  $$('p#notice, p#warning, p#error').each(function(e) { 
    if (e) Effect.Fade(e, { duration: 5.0 });
  });
}