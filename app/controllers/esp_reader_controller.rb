class EspReaderController < ApplicationController

  def upload
    respond_to do |format|
      format.html
      format.json {}
    end
  end

  def update

    esp = EspReader.new
    esp.unpack(params[:esp_upload][:zip].tempfile.path)
    redirect_to confirm_esp_reader_index_path

  end

end
