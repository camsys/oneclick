# encoding: utf-8

class PoiUploader < BaseUploader

  def extension_white_list
    %w(csv)
  end

  def store_dir
    "uploads/pois"
  end

end
