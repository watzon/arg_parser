module ArgParser::EpochConverter
  def self.from_arg(arg)
    Time.epoch(arg.to_i64)
  end
end
