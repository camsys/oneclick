class ArcEligibilityVeteranUpMedicaidDown < ActiveRecord::Migration
  def change
  	if Oneclick::Application.config.brand == 'arc'
	  	veteran = Characteristic.find_by_code('veteran')
	  	unless veteran.nil?
	  		veteran.update_attributes(ask_early: true)
	  	end
	  	medicaid = Characteristic.find_by_code('nemt_eligible')
	  	unless medicaid.nil?
	  		medicaid.update_attributes(ask_early: false)
	  	end
	  end
  end
end
