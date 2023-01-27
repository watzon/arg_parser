# ArgParser

[![Tests](https://github.com/watzon/arg_parser/actions/workflows/crystal.yml/badge.svg)](https://github.com/watzon/arg_parser/actions/workflows/crystal.yml) 

A powerful argument parser which uses a class or struct to define the arguments and their types.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     arg_parser:
       github: watzon/arg_parser
   ```

2. Run `shards install`

## Usage

ArgParser works very similarly to `JSON::Serializable` and works on both classes and structs. To use it, simply include ArgParser in your class or struct, and define the arguments you want to parse as instance variables.

```crystal
struct MyArgs
  include ArgParser

  getter name : String
  getter age : Int32
  getter active : Bool
end
```

ArgParser parses arguments such as those that come from `ARGV`, though in reality all that really matters is that it's given an array of strings. ArgParser defines an initializer for your type which takes the array of strings, and parses it into your type.

```crystal
args = MyArgs.new(["--name", "John Doe", "--age", "20", "--active"])
args.name   # => "John Doe"
args.age    # => 20
args.active # => true
```

Positional arguments are supported as well. To keep things in your struct clean, all instance variables added by ArgParser itself are prefixed with an underscore.

```crystal
args = MyArgs.new(["\"Hello world\"", --name", "John Doe", "--age", "20", "--active"])
args._positional_args # => ["Hello world"]
```

## Supported Types

By default ArgParser supports the following types:
* `String`
* `Int`
* `UInt`
* `Float`
* `BigInt`
* `BigFloat`
* `BigDecimal`
* `BigRational`
* `Bool`
* `URI`
* `UUID`

Any type which implements `from_arg` can be used as an argument type.
For types which don't implement `from_arg`, you can define a converter
which implements `from_arg` as a proxy for that type.

## Converters

Converers are simply modules which have a `self.from_arg` method which takes
a value string, and returns the converted value. For Example:

```
module MyConverter
  def self.from_arg(value : String)
    # do something with value
  end
end
```

Converters can be used through the `ArgParser::Field` annotation.

```crystal
struct MyArgs
  include ArgParser

  @[ArgParser::Field(converter: MyConverter)]
  getter name : SomeType
end
```

# Aliases

Aliases are simply other names for an argument. For example, if you want to use
`-n` as an alias for `--name`, you can do so with the `ArgParser::Field` annotation.

```crystal
struct MyArgs
  include ArgParser

  @[ArgParser::Field(alias: "-n")]
  getter name : String
end
```

Currently only a single alias is supported.

## Default Values

Default values can be specified in the same way you would normally specify them in Crystal. For example, if you want to set a default value for `name`:

```crystal
struct MyArgs
  include ArgParser

  getter name : String = "John Doe"
end
```

## Validators

Validators allow you to validate user input. For example, if you want to make sure that the user's input matches a pattern, you can do so with a validator.

```crystal
struct MyArgs
  include ArgParser

  @[ArgParser::Validate::Format(/[a-zA-Z]+/)]
  getter name : String
end
```

On invalid input, the method `on_validation_error` is called. By default, this method raises an `ArgParser::ValidationError`, but you can override it to do whatever you want.

```crystal
struct MyArgs
  include ArgParser

  @[ArgParser::Validate::Format(/[a-zA-Z]+/)]
  getter name : String

  def on_validation_error(field : Symbol, value, errors : Array(String))
    # allow it, but print a warning
    puts "Invalid value for #{field}: #{value}"
  end
end
```

All validation errors are also added to the `_validation_errors` hash. This can be useful if you want to do something with the errors after parsing.

```crystal
args = MyArgs.new(["--name", "John Doe", "--age", "foo", "--active"])
args._validation_errors # => {"age" => ["must be an integer"]}
```

## Modifying the Behavior of ArgParser

ArgParser is designed to be configurable so it can handle a wide variety of use cases. As such, it includes several overridable methods which can be used to modify its behavior. These are:

- `on_validation_error` - called when a validation error occurs; by default calls `add_validation_error` and then raises `ArgParser::ValidationError`
- `on_unknown_attribute` - called when an unknown attribute is encountered; by default raises `ArgParser::UnknownAttributeError`
- `on_missing_attribute` - called when a required attribute is missing; by default raises `ArgParser::MissingAttributeError`
- `on_conversion_error` - called when a value isn't able to be converted to the specified type; by default raises `ArgParser::ConversionError`

In addition, the way keys are parsed can be modified by overriding the `parse_key` method. By default, it simply removes one or two dashes from the beginning of the key. For example, `--name` becomes `name`, and `-n` becomes `n`.

## Contributing

1. Fork it (<https://github.com/your-github-user/arg_parser/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Watson](https://github.com/your-github-user) - creator and maintainer
