var loginView = {
};

loginView.init = function () {

  alert("LOGIN VIEW INIT");

  $('input#user_email').click(function(){
      alert("CLICK EMAIL");
       //if (window.cocoa)
       // window.cocoa.openKeyboard();
  });

  $('input#user_email').blur(function(){
      alert("BLUR EMAIL");
      //if (window.cocoa)
      //  window.cocoa.closeKeyboard();
  });

  $('input#user_password').click(function(){
      alert("CLICK PASSWORD");
       //if (window.cocoa)
       // window.cocoa.openKeyboard();
  });

  $('input#user_password').blur(function(){
      alert("BLUR PASSWORD");
      //if (window.cocoa)
      //  window.cocoa.closeKeyboard();
  });

};

$(document).ready(function () {
  "use strict";

  //kick everything off
  loginView.init();

});
