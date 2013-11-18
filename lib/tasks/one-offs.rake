#encoding: utf-8
namespace :oneclick do
  namespace :one_offs do
    desc "Modify characteristics"
    task :modify_characteristics => :environment do
      [{code: 'disabled', desc: 'persons with disabilities'},
        {code: 'no_trans', desc: 'persons with no means of transportation'},
        {code: 'nemt_eligible', desc: 'persons eligible for Medicaid'},
        {code: 'ada_eligible', desc: 'persons eligible for ADA Paratarnsit'},
        {code: 'veteran', desc: 'military veterans'}].each do |c|
          t = TravelerCharacteristic.find_by_code(c[:code])
          t.update_attributes! desc: c[:desc]
        end
        TravelerCharacteristic.find_by_code('low_income').update_attributes! name: 'low income individuals'

        [{code: 'folding_wheelchair_acceessible', name: 'Folding wheelchair access'},
          {code: 'motorized_wheelchair_accessible', name: 'Motorized wheelchair access'},
          {code: 'lift_equipped', name: 'Wheelchair lift equipped vehicles'},
          {code: 'door_to_door', name: 'Door-to-door assistance'},
          {code: 'curb_to_curb', name: 'Curb-to-curb service'},
          {code: 'driver_assistance_available', name: 'Driver assistance'}].each do |c|
            t = TravelerAccommodation.find_by_code(c[:code])
            t.update_attributes! name: c[:name]
          #
        end

    end # task

  end
end
