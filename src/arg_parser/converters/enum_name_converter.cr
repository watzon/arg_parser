module ArgParser::EnumNameConverter(E)
  def self.from_arg(arg)
    E.parse(arg)
  end
end
