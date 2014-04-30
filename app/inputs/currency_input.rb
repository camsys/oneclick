# app/inputs/currency_input.rb
class CurrencyInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options)
    "$ #{@builder.text_field(attribute_name, input_html_options)}".html_safe
  end
end
