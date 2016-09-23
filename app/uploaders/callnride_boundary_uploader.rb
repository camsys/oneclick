# encoding: utf-8

class CallnrideBoundaryUploader < BaseUploader

  def extension_white_list
    %w(zip)
  end

  def store_dir
    "uploads/callnrides"
  end

end
