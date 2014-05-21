class EspReaderController < ApplicationController
  authorize_resource

  def upload
    respond_to do |format|
      format.html
      format.json {}
    end
  end

  def update

    esp = EspReader.new

    if params[:esp_upload].nil? || params[:esp_upload][:zip].nil?
      flash[:error] = "No file selected."
      @path = upload_esp_reader_index_path

    else
      result, message = esp.unpack(params[:esp_upload][:zip].tempfile.path, (params[:esp_upload][:csv]=='0' ? :mdb : :csvzip))
      if result
        @path = services_path
        flash[:notice] = "ESP services updated successfully."
      else
        @path = upload_esp_reader_index_path
        flash[:error] = message
      end

    end

    respond_to do |format|
      format.html { redirect_to @path }
      #format.js { render "esp_reader/uploadd" }
    end

  end

end
