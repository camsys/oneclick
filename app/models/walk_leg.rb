class WalkLeg < Leg

    before_create :set_mode, on: :create

    def set_mode
      self.mode = WalkLeg
    end

    def short_description
      desc = [TranslationEngine.translate_text(mode.downcase.to_sym), TranslationEngine.translate_text(:to), end_place.name].join(' ')
    end

end