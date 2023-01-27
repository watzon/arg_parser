module ArgParser::EpochMillisConverter
  def self.from_arg(arg)
    Time.unix_ms(arg.to_i64)
  end
end
