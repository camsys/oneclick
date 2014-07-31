class Admin::BaseController < ApplicationController
  check_authorization # Be cautious when removing this.  It brings a lot to the table.
  
  # # cancan authorization for the controller
  # authorize_resource :class => false
  
end
