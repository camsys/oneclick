var loginView = {
};

loginView.init = function () {

  $('input#user_email').click(function(){
       if (window.cocoa)
        window.cocoa.openKeyboard();
  });

  $('input#user_email').blur(function(){
      alert("IN BLUR, BEFORE COCOA CHECK");
      if (window.cocoa)
      {
        alert("IN BLUR COCOA");
        window.cocoa.closeKeyboard();
      }
  });

  $('input#user_password').click(function(){
       if (window.cocoa)
        window.cocoa.openKeyboard();
  });

  $('input#user_password').blur(function(){
      if (window.cocoa)
        window.cocoa.closeKeyboard();
  });

};

$(document).ready(function () {
  "use strict";

  //kick everything off
  loginView.init();

});
