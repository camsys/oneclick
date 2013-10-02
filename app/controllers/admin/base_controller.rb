class Admin::BaseController < ApplicationController

  # cancan authorization for the controller
  authorize_resource :class => false
  
end
