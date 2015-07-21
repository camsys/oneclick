module CsvStreaming
  extend ActiveSupport::Concern
  
  private 

  def render_csv(file_name, rel, headers)
    set_file_headers file_name
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines(rel, headers)
  end


  def set_file_headers(file_name)
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end


  def set_streaming_headers
    #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def csv_lines(rel, headers)
    
    Enumerator.new do |y|
      y << headers.to_csv

      rel.find_each { |row| y << row.to_csv }
    end

  end
end