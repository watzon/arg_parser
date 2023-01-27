module ArgParser::EnumValueConverter(E)
  def self.from_arg(arg)
    E.from_value(arg.to_i64)
  end
end
