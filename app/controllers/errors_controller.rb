class ErrorsController < ApplicationController
  def error_404
    respond_to do |format|
      format.html { render status: 404 }
      format.any  { render text: t(:http_404_not_found), status: 404 }
    end
  end

  def error_422
    respond_to do |format|
      format.html { render status: 422 }
      format.any  { render text: t(:http_422_unprocessable_entity), status: 422 }
    end
  end

  def error_500
    render file: "#{Rails.root}/public/500.html", layout: false, status: 500
  end

  def error_501
    respond_to do |format|
      format.html { render status: 501 }
      format.any  { render text: t(:http_501_not_implemented), status: 501 }
    end
  end

end
