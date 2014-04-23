
# Transient class used to aggregate user characteristics so they
# can be updated in a single form.
class UserProfileProxy < Proxy

  PARAM_NOT_SET = "na"

  attr_accessor :user

  def initialize(user = nil)
    super
    self.user ||= user
  end

  def id
    return 1
  end

  # Convert the params into a typed value for the database. For most types the params list is a single hash {"x" = "y"}. For
  # date fields the hash for Jan 8 2001 looks like  {"date_of_birth(2i)"=>"1", "date_of_birth(3i)"=>"8", "date_of_birth(1i)"=>"2001"}
  def convert_value(characteristic, params)
    ret = case characteristic.datatype
    when 'bool'
      params[characteristic.code].blank? || params[characteristic.code] == PARAM_NOT_SET ? nil : params[characteristic.code]
    when 'integer'
      params[characteristic.code].blank? ? nil : params[characteristic.code].to_i
    when 'date'
      if params.length == 1
        # it is a datestring, not a rails date form field.
        date_str = params.values.first
        date_str = if (y,m,d = date_str.split('-')).length < 3
          "1-1-#{date_str}"
        else
          "#{d}-#{m}-#{y}"
        end
      else
        a = []
        params.each do |d|
          a << d[1]
        end
        locale = I18n.locale.to_s
        Rails.logger.debug "Locale is set to: " + locale
        if locale == 'en'
          month = a[1]
          day = a[0]
        else
          month = a[0]
          day = a[1]
        end
        year = a[2]
        date_str = day + '/' + month + '/' + year
      end

      Rails.logger.debug "Parsing date: " + date_str if date_str.present?

      params.empty? ? nil : Chronic.parse(date_str)
    end

    return ret
  end

  # coerce value into a type based on the data type
  def coerce_value(characteristic, user_characteristic)
    type = characteristic.datatype
    if type == 'bool'
      ret = user_characteristic.nil? ? PARAM_NOT_SET : user_characteristic.value
    elsif type == 'integer'
      ret = user_characteristic.nil? ? 0 : user_characteristic.value.to_i
    elsif type == 'date'

      # TODO We probably need a separate datatype for age
      #Note, Chronic.parse returns nil for value = "false"
      ret = (user_characteristic.nil? || Chronic.parse(user_characteristic.value).nil?) ? nil : Chronic.parse(user_characteristic.value).year
    end

    return ret
  end

  # coerce value into a localized description based on the data type
  # returns a string if it can be displayed as stored (dates and numbers)
  # returns a symbol if it needs to be localied
  def coerce_value_to_string(characteristic, user_characteristic)
    if user_characteristic.nil? 
      return :no_answer_str
    else
      type = characteristic.datatype
      if type == 'bool' # column is saved as a varchar "true"/"false", convert to symbol representing "yes"/"no"
        ret = (user_characteristic.value == "true") ? :yes_str : :no_str 
      elsif type == 'integer' # All other cases, just pass value (numbers and dates are already internationalized)
        ret = user_characteristic.value
      elsif type == 'date'
        ret = Chronic.parse(user_characteristic.value).to_s
      end

      return ret
    end
  end

end
