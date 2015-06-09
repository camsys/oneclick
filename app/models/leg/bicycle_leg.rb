class BicycleLeg < Leg

    def initialize(attrs = {})

      super(attrs)
      attrs.each do |k, v|
        self.send "#{k}=", v
      end

      self.mode = BICYCLE

    end

    def short_description
      desc = [TranslationEngine.translate_text(mode.downcase.to_sym), TranslationEngine.translate_text(:to), end_place.name].join(' ')
    end

end