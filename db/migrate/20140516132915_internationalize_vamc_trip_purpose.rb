class InternationalizeVamcTripPurpose < ActiveRecord::Migration
  #Modify the VAMC trip purpose (specific to PA) to the internationalized form
  def change
    if tp = TripPurpose.find_by_name('Visit Lebanon VA Medical Center') # if purpose is named properly in the first place or we're not in the PA instance, don't run this code
      code = 'vamc'
      tp.update_attributes(
          code: code,
          name: code + "_name",
          note: code + "_note"
          )
      %w(en es).each do |locale|
        Translation.create!(key: code+"_name", value: "Visit Lebanon VA Medical Center", locale: locale)
        Translation.create!(key: code+"_note", value: "Visit Lebanon VA Medical Center", locale: locale)
      end
    end
  end
end
