module ArgParser::EpochMillisConverter
  def self.from_arg(arg)
    Time.epoch_ms(arg.to_i64)
  end
end
