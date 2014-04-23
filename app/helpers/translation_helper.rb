module TranslationHelper
  def human_readable(input)
    case input
    when Symbol
      t(input)
    when String
      input
    end
  end
end
