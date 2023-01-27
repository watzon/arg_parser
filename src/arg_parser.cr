require "json"
require "./arg_parser/*"
require "./arg_parser/validators/*"
require "./arg_parser/converters/*"

# A powerful argument parser which uses a class or struct to
# define the arguments and their types.
module ArgParser
  annotation Field; end

  @[ArgParser::Field(ignore: true)]
  getter _positional_args : Array(String)

  @[ArgParser::Field(ignore: true)]
  getter _validation_errors : Hash(String, Array(String))

  @[ArgParser::Field(ignore: true)]
  getter _field_names : Array(String)

  # Create a new {{@type}} from an array of arguments.
  # See: https://github.com/watzon/arg_parser for more information.
  def initialize(args : Array(String))
    @_positional_args = [] of String
    @_validation_errors = {} of String => Array(String)
    @_field_names = [] of String
    {% begin %}
      %args = args.clone
      {% properties = {} of Nil => Nil %}
      {% for ivar in @type.instance_vars %}
        {% ann = ivar.annotation(ArgParser::Field) %}
        {% unless ann && ann[:ignore] %}
          @_field_names << {{ivar.id.stringify}}
          {% if ann && ann[:alias] %}
            @_field_names << {{ann[:alias].id.stringify}}
          {% end %}

          {%
            properties[ivar.id] = {
              type:        ivar.type,
              key:         ((ann && ann[:key]) || ivar).id.stringify,
              has_default: ivar.has_default_value?,
              default:     ivar.default_value,
              nilable:     ivar.type.nilable?,
              converter:   ann && ann[:converter],
              presence:    ann && ann[:presence],
              alias:       ann && ann[:alias],
              validators:  [] of Nil,
            }
          %}

          {% for validator in ArgParser::Validator.all_subclasses.reject { |k| k.abstract? } %}
            {% v_ann = validator.constant("ANNOTATION").resolve %}
            {% if ann = ivar.annotation(v_ann) %}
              {% properties[ivar.id][:validators] << {ann, validator} %}
            {% end %}
          {% end %}
        {% end %}
      {% end %}

      {% for name, value in properties %}
        %var{name} = {% if value[:type] < Array %}[] of {{value[:type].type_vars[0]}}{% else %}nil{% end %}
        %found{name} = false
      {% end %}

      i = 0
      while !%args.empty?
        arg = %args.shift
        key = parse_key(arg)
        next unless key

        value = %args.shift rescue "true"
        if value.starts_with?("-")
          %args.unshift(value)
          value = "true"
        end

        case key
        {% for name, value in properties %}
          when {{ value[:key].id.stringify }}{% if value[:alias] %}, {{ value[:alias].id.stringify }}{% end %}
            %found{name} = true
            begin
              {% if value[:type] == String %}
                %var{name} = value
              {% elsif value[:type] < Array %}
                %var{name} ||= [] of {{value[:type].type_vars[0]}}
                {% if value[:converter] %}
                  %var{name}.concat {{ value[:converter] }}.from_arg(value)
                {% else %}
                  %var{name} << ::Union({{value[:type].type_vars[0]}}).from_arg(value)
                {% end %}
              {% else %}
                {% if value[:converter] %}
                  %var{name} = {{ value[:converter] }}.from_arg(value)
                {% else %}
                  %var{name} = ::Union({{value[:type]}}).from_arg(value)
                {% end %}
              {% end %}
            rescue
              on_conversion_error({{value[:key].id.stringify}}, value, {{value[:type]}})
            end
          {% end %}
        else
          on_unknown_attribute(key)
        end
      end

      {% for name, value in properties %}
        {% unless value[:nilable] || value[:has_default] %}
          if %var{name}.nil? && !%found{name} && !::Union({{value[:type]}}).nilable?
            on_missing_attribute({{value[:key].id.stringify}})
          end
        {% end %}

        {% if value[:nilable] %}
          {% if value[:has_default] != nil %}
            @{{name}} = %found{name} ? %var{name} : {{value[:default]}}
          {% else %}
            @{{name}} = %var{name}
          {% end %}
        {% elsif value[:has_default] %}
          if %found{name} && !%var{name}.nil?
            @{{name}} = %var{name}
          end
        {% else %}
          @{{name}} = (%var{name}).as({{value[:type]}})
        {% end %}

        {% if value[:presence] %}
          @{{name}}_present = %found{name}
        {% end %}

        {% for v in value[:validators] %}
          {%
            ann = v[0]
            validator = v[1]
            args = [] of String
          %}

          {% for arg in ann.args %}
              {% args << arg.stringify %}
          {% end %}

          {% for k, v in ann.named_args %}
              {% args << "#{k.id}: #{v.stringify}" %}
          {% end %}

          %validator{name} = {{ validator.name(generic_args: false) }}.new({{ args.join(", ").id }})
          if %found{name} && !%validator{name}.validate({{name.id.stringify}}, @{{name}})
            on_validation_error({{name.stringify}}, @{{name}}, %validator{name}.errors)
          end
        {% end %}
      {% end %}
    {% end %}
  end

  # Parse the argument key.
  # Standard arg names start with a `--`
  # Aliases start with a single `-`
  #
  # Note: You can override this method to change the way keys are parsed.
  def parse_key(arg : String) : String?
    if arg.starts_with?("--")
      key = arg[2..-1]
    elsif arg.starts_with?("-")
      key = arg[1..-1]
    else
      @_positional_args << arg
      nil
    end
  end

  # Called when an unknown attribute is found.
  #
  # Note: You can override this method to change the way unknown attributes are handled.
  def on_unknown_attribute(key : String)
    raise UnknownAttributeError.new(key)
  end

  # Called when a required attribute is missing.
  #
  # Note: You can override this method to change the way missing attributes are handled.
  def on_missing_attribute(key : String)
    raise MissingAttributeError.new(key)
  end

  # Called when a validation error occurs.
  #
  # Note: You can override this method to change the way validation errors are handled.
  def on_validation_error(key : String, value, errors : Array(String))
    add_validation_error(key, errors)
    raise ValidationError.new(key, value, errors)
  end

  # Called when a value cannot be converted to the expected type.
  #
  # Note: You can override this method to change the way conversion errors are handled.
  def on_conversion_error(key : String, value : String, type)
    raise ConversionError.new(key, value, type)
  end

  def add_validation_error(key : String, errors : Array(String))
    @_validation_errors[key] ||= [] of String
    @_validation_errors[key].concat errors
  end

  # https://en.wikipedia.org/wiki/Quotation_mark#Summary_table
  QUOTE_CHARS = {'"' => '"', '“' => '”', '‘' => '’', '«' => '»', '‹' => '›', '❛' => '❜', '❝' => '❞', '❮' => '❯', '＂' => '＂'}

  # Convert the string input into an array of tokens.
  # Quoted values should be considered one token, but everything
  # else should be split by spaces.
  # Should work with all types of quotes, and handle nested quotes.
  # Unmatched quotes should be considered part of the token.
  #
  # Example:
  # ```
  # input = %q{foo "bar baz" "qux \\"quux" "corge grault}
  # tokenize(input) # => ["foo", "bar baz", "qux \"quux", "\"corge", "grault"]
  # ```
  def self.tokenize(input : String)
    tokens = [] of String
    current_token = [] of Char
    quote = nil
    input.each_char do |char|
      if quote
        if char == quote
          quote = nil
        else
          current_token << char
        end
      else
        if QUOTE_CHARS.has_key?(char)
          quote = QUOTE_CHARS[char]
        elsif char == ' '
          if current_token.any?
            tokens << current_token.join
            current_token.clear
          end
        else
          current_token << char
        end
      end
    end
    tokens << current_token.join if current_token.any?
    tokens.reject(&.empty?)
  end
end
