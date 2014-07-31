module InterestingAttributes
  def interesting_attributes
    attributes.reject{|k, v| ['created_at', 'updated_at'].include? k}
  end
end
