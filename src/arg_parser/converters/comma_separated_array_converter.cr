module ArgParser::CommaSeparatedArrayConverter(SubConverter)
  def self.from_arg(arg)
    arg.split(/,\s*/).map do |a|
      SubConverter.from_arg(a)
    end
  end
end
