module Sass::Script::Functions
  def getenv(name, default)

    #Convert from Sass::Script::String into String
    #Conveting name to string leaves the quotes as part of the string they need to be removed
    name = name.to_s[1..-2] #Remove first and last character (e.g., ""VARIABLE NAME"" becomes "VARIABLE NAME")

    value = ENV.fetch(name, nil)

    if not value
      return Sass::Script::Parser.parse('#555555', 0, 0)
      return default
    end

    begin
      puts 'trying'
      Sass::Script::Parser.parse(value, 0, 0)
    rescue
      Sass::Script::String.new(value)
    end
  end
end