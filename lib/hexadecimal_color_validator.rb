#hexadecimal_color_validator.rb
 
class HexadecimalColorValidator < ActiveModel::Validator
  def validate(record)
  	return false if record.display_color.blank?
  	record.display_color.insert(0,"#") if record["display_color"][0] != "#"
  	color_value = record["display_color"]
  	isValid = /^#(?:[0-9a-f]{3})(?:[0-9a-f]{3})?$/i.match(color_value).nil? ? false : true
    record.errors["display_color"] << (options[:message] || 'is not a valid hexadecimal color') unless isValid
  end
end