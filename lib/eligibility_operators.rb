module EligibilityOperators
  EQ = 1
  EQ_F = 2
  GT = 3
  GE = 4
  LT = 5
  LE = 6

  def test_condition(value1, operator, value2)
    case operator
      when EQ # general equals
        return value1 == value2
      when EQ_F # float equals
        return value1.to_f == value2.to_f
      when GT # greater than
        return value1.to_f > value2.to_f
      when GE # greather than or equal
        return value1.to_f >= value2.to_f
      when LT # less than
        return value1.to_f < value2.to_f
      when LE # less than or equal
        return value1.to_f <= value2.to_f
      else
        return false
      end
  end

  def relationship_to_words(operator)
    case operator
      when EQ # general equals
        return "equal to"
      when EQ_F # float equals
        return "equal to"
      when GT # greater than
        return "greater than"
      when GE # greather than or equal
        return "at least"
      when LT # less than
        return "less than"
      when LE # less than or equal
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
      when EQ # general equals
        return "=="
      when EQ_F # float equals
        return "=="
      when GT # greater than
        return ">"
      when GE # greather than or equal
        return ">="
      when LT # less than
        return "<"
      when LE # less than or equal
        return "<="
      else
        raise Exception.new("Unknown relationship operator #{operator}")
    end
  end

  def reverse_relationship_to_symbol(operator)
    case operator
      when EQ # general equals
        return "!="
      when EQ_F # float equals
        return "!="
      when GT # greater than
        return "<="
      when GE # greather than or equal
        return "<"
      when LT # less than
        return ">="
      when LE # less than or equal
        return ">"
      else
        raise Exception.new("Unknown relationship operator #{operator}")
    end
  end
end
