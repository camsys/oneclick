# encoding: utf-8

class ApplicationLogoUploader < BaseUploader

  process :resize_to_fit => Oneclick::Application.config.application_logo_dimensions || [2000, 200]

  def extension_white_list
    Oneclick::Application.config.application_logo_format_list
  end

  def store_dir
    "uploads/logo"
  end

end
