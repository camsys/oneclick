class Leg::CarLeg < Leg

  def initialize(attrs = {})

    super(attrs)
    attrs.each do |k, v|
      self.send "#{k}=", v
    end

    self.mode = CAR

  end

  def short_description
    [TranslationEngine.translate_text(:drive_or_taxi), TranslationEngine.translate_text(:to), end_place.name].join(' ')
  end

end