module SeedsHelpers
  ## Creates seed and sample records with internationalized keys
  # expects a hash of the following form
  #   {klass: TripPurpose,
  #     code: 'dialysis',
  #     :xlate: {
  #           name: 'Dialysis',
  #           note: 'Dialysis appointment.'
  #      },
  #     :no_xlate: {
  #           active: 1,
  #           sort_order: 2}
  #       }
  def build_internationalized_records p
    begin
      record = p[:klass].find_by(code: p[:code]) || p[:klass].new
      record[:code] = p[:code]
      p[:xlate].each do |k,v|
        translation_fkey = "#{p[:code]}_#{k}"
        I18n.available_locales.each do |locale|
          Translation.find_or_create_by!(key: translation_fkey, locale: locale) do |t|
            if locale.eql? :en
              t.value = v
            else
              t.value = "[#{locale}]#{v}[/#{locale}]"
            end
          end
        end
        record[k] = translation_fkey
      end
      p[:no_xlate].each do |k,v|
        record[k] = v
      end
      record.save!
    rescue Exception => e
      puts "Failed to save #{p.ai} because: #{e.message}"
      raise e
    end
    return record
  end

  ## Take a flat hash and structure it, for the build_internationalized_records function
  def structure_records_from_flat_hash h
    rtn = {}
    rtn[:klass] = h.delete :klass
    rtn[:code] = h.delete :code
    rtn[:xlate] = h.extract! :name, :note, :desc
    rtn[:no_xlate] = h
    return rtn
  end
end
