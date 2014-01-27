var loginView = {
};

loginView.init = function () {

  $('input#kiosk_user_email').click(function(){
       if (window.cocoa)
        window.cocoa.openKeyboard();
  });

  $('input#kiosk_user_password').click(function(){
       if (window.cocoa)
        window.cocoa.openKeyboard();
  });

};

$(document).ready(function () {
  "use strict";

  //kick everything off
  loginView.init();

});
