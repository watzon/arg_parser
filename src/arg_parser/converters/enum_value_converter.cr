module ArgParser::EnumValueConverter(E)
  def self.from_arg(arg)
    E.new(arg)
  end
end
