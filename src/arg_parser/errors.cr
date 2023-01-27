module ArgParser
  class Error < Exception; end

  class UnknownAttributeError < Error
    getter attr : String

    def initialize(@attr : String)
      raise "Unknown attribute: #{@attr}"
    end
  end

  class MissingAttributeError < Error
    getter attr : String

    def initialize(@attr : String)
      raise "Missing required attribute: #{@attr}"
    end
  end

  class ValidationError < Error
    def initialize(name, value, errors)
      super("Validation failed for field :#{name} with value #{value.inspect}:\n" +
            errors.map { |e| "  - #{e}" }.join("\n"))
    end
  end

  class ConversionError < Error
    def initialize(name, value, type)
      super("Failed to convert #{value} to #{type} for field :#{name}")
    end
  end
end
