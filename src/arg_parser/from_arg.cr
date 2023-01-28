class String
  def self.from_arg(arg : String)
    arg
  end
end

struct Int8
  def self.from_arg(arg : String)
    arg.to_i8
  end
end

struct Int16
  def self.from_arg(arg : String)
    arg.to_i16
  end
end

struct Int32
  def self.from_arg(arg : String)
    arg.to_i32
  end
end

struct Int64
  def self.from_arg(arg : String)
    arg.to_i64
  end
end

struct Int128
  def self.from_arg(arg : String)
    arg.to_i128
  end
end

struct UInt8
  def self.from_arg(arg : String)
    arg.to_u8
  end
end

struct UInt16
  def self.from_arg(arg : String)
    arg.to_u16
  end
end

struct UInt32
  def self.from_arg(arg : String)
    arg.to_u32
  end
end

struct UInt64
  def self.from_arg(arg : String)
    arg.to_u64
  end
end

struct UInt128
  def self.from_arg(arg : String)
    arg.to_u128
  end
end

struct Float32
  def self.from_arg(arg : String)
    arg.to_f32
  end
end

struct Float64
  def self.from_arg(arg : String)
    arg.to_f64
  end
end

struct Bool
  def self.from_arg(arg : String)
    arg.downcase.in?(%w(true t yes y 1))
  end
end

class BigInt
  def self.from_arg(arg : String)
    BigInt.new(arg)
  end
end

class BigFloat
  def self.from_arg(arg : String)
    BigFloat.new(arg)
  end
end

class BigRational
  def self.from_arg(arg : String)
    # BigRational can be instantiated with:
    # - a numerator and a denominator
    # - a single integer
    # - a single float
    # We need to try them all
    if arg.includes?('/')
      numerator, denominator = arg.split('/')
      BigRational.new(numerator.to_i64, denominator.to_i64)
    elsif arg.includes?('.')
      BigRational.new(arg.to_f64)
    else
      BigRational.new(arg.to_i64)
    end
  end
end

class URI
  def self.from_arg(arg : String)
    URI.parse(arg)
  end
end

struct UUID
  def self.from_arg(arg : String)
    UUID.new(arg)
  end
end

struct Nil
  def self.from_arg(arg : String)
    nil
  end
end

def Union.from_arg(arg : String)
  {% begin %}
    {% for type in T %}
      {% if type != Nil %}
        begin
          %val = {{type}}.from_arg(arg)
          return %val if %val.is_a?({{type}})
        rescue
        end
      {% end %}
    {% end %}

    {% if T.includes?(Nil) %}
      nil
    {% else %}
      raise ArgParser::Error.new("Argument '#{arg}' cannot be converted to any of the union types: {{T}}")
    {% end %}
  {% end %}
end
