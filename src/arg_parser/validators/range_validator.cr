module ArgParser::Validators
  class RangeValidator(B, E) < ArgParser::Validator
    ANNOTATION = Validate::InRange

    def initialize(b : B, e : E)
      @range = Range(B, E).new(b, e)
    end

    def validate(name, input) : Bool
      return true if @range.includes?(input)
      errors << "input for #{name.to_s} must be in range #{@range}"
      false
    end
  end
end
