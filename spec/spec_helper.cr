require "../src/arg_parser"
require "spectator"

require "uri"
require "uuid"

struct TestSupportedArgs
  include ArgParser

  getter name : String

  getter age : Int32

  getter height : Float64

  getter is_human : Bool

  getter website : URI

  getter id : UUID
end

enum Color
  Red
  Green
  Blue
end

struct TestConverters
  include ArgParser

  @[ArgParser::Field(converter: ArgParser::CommaSeparatedArrayConverter(Int32))]
  getter ids : Array(Int32)

  @[ArgParser::Field(converter: ArgParser::EpochConverter)]
  getter unix : Time

  @[ArgParser::Field(converter: ArgParser::EpochMillisConverter, key: "unix-ms")]
  getter unix_ms : Time

  @[ArgParser::Field(converter: ArgParser::EnumNameConverter(Color))]
  getter color : Color

  @[ArgParser::Field(converter: ArgParser::EnumValueConverter(Color))]
  getter ncolor : Color
end

struct TestValidators
  include ArgParser

  @[ArgParser::Validate::Format(/^[a-zA-Z]+$/)]
  getter first_name : String

  @[ArgParser::Validate::Format(/^[a-zA-Z]+$/)]
  getter last_name : String?

  @[ArgParser::Validate::InRange(1, 100)]
  getter age : Int32
end
