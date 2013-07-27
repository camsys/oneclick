class ErrorsController < ApplicationController
  def error_404
    respond_to do |format|
      format.html { render status: 404 }
      format.any  { render text: "404 Not Found", status: 404 }
    end
  end

  def error_422
    respond_to do |format|
      format.html { render status: 422 }
      format.any  { render text: "422 Unprocessable Entity", status: 422 }
    end
  end

  def error_500
    render file: "#{Rails.root}/public/500.html", layout: false, status: 500
  end

  def error_501
    respond_to do |format|
      format.html { render status: 501 }
      format.any  { render text: "501 Not Implemented", status: 501 }
    end
  end

end
