module ArgParser::EpochConverter
  def self.from_arg(arg)
    Time.unix(arg.to_i64)
  end
end
