class Admin::BaseController < ApplicationController
  check_authorization
  
  # # cancan authorization for the controller
  # authorize_resource :class => false
  
end
