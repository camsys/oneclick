# encoding: utf-8

class ServiceLogoUploader < BaseUploader

  process :resize_to_fit => Oneclick::Application.config.service_logo_dimensions || [40, 40]

  def extension_white_list
    Oneclick::Application.config.service_logo_format_list
  end

end
