module ArgParser
  abstract class Validator
    getter errors = [] of String

    abstract def validate(name, input) : Bool
  end
end
