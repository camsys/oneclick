# encoding: utf-8

class FaviconUploader < BaseUploader

  def extension_white_list
    Oneclick::Application.config.favicon_format_list
  end

  def store_dir
    "uploads/favicon"
  end

end
