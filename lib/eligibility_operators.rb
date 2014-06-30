module EligibilityOperators
  def test_condition(value1, operator, value2)
    case operator
      when 1 # general equals
        return value1 == value2
      when 2 # float equals
        return value1.to_f == value2.to_f
      when 3 # greater than
        return value1.to_f > value2.to_f
      when 4 # greather than or equal
        return value1.to_f >= value2.to_f
      when 5 # less than
        return value1.to_f < value2.to_f
      when 6 # less than or equal
        return value1.to_f <= value2.to_f
      else
        return false
      end
  end

  def relationship_to_words(operator)
    case operator
      when 1 # general equals
        return "equal to"
      when 2 # float equals
        return "equal to"
      when 3 # greater than
        return "greater than"
      when 4 # greather than or equal
        return "at least"
      when 5 # less than
        return "less than"
      when 6 # less than or equal
        return "at most"
      else
        return ""
    end
  end

  def operator_select_options
    (1..6).map { |op| [relationship_to_words(op), op] }
  end
  
  def relationship_to_symbol(operator)
    case operator
      when 1 # general equals
        return "=="
      when 2 # float equals
        return "=="
      when 3 # greater than
        return ">"
      when 4 # greather than or equal
        return ">="
      when 5 # less than
        return "<"
      when 6 # less than or equal
        return "<="
      else
        raise Exception.new("Unknown relationship operator #{operator}")
    end
  end

  def reverse_relationship_to_symbol(operator)
    case operator
      when 1 # general equals
        return "!="
      when 2 # float equals
        return "!="
      when 3 # greater than
        return "<"
      when 4 # greater than or equal
        return "<="
      when 5 # less than
        return ">"
      when 6 # less than or equal
        return ">="
      else
        raise Exception.new("Unknown relationship operator #{operator}")
    end
  end
end
