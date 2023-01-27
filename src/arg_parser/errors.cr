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
    def initialize(name, errors)
      super("Validation failed for #{name}: #{errors.join(", ")}")
    end
  end

  class ConversionError < Error
    def initialize(name, value, type)
      super("Failed to convert #{value} to #{type} for field :#{name}")
    end
  end
end
