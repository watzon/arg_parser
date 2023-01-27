module ArgParser::Validators
  class FormatValidator < ArgParser::Validator
    ANNOTATION = Validate::Format

    def initialize(@regex : Regex)
    end

    def validate(name, input) : Bool
      return true if @regex =~ input.to_s
      errors << "#{name} must match pattern /#{@regex.source}/"
      false
    end
  end
end
