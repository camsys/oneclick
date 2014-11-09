class SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    if current_user.preferred_modes.present?
      session[:modes_desired] = current_user.preferred_modes.pluck(:code)
    end
    redirect_to_path = params[:user][:redirect_to] rescue nil #TOOD: should check if URI valid?
    unless redirect_to_path.nil?
      redirect_to redirect_to_path.to_s
    else
      respond_with resource, :location => after_sign_in_path_for(resource)
    end
  end
end