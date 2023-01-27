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
