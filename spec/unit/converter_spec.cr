require "../spec_helper"

Spectator.describe "ArgParser converters" do
  let(args) { ["--ids", "1,2,3,4", "--unix", "1674843165", "--unix-ms", "1674843241159", "--color", "red", "--ncolor", "2"] }
  let(parser) { TestConverters.new(args) }

  it "converts comma separated list to array" do
    expect(parser.ids).to eq [1, 2, 3, 4]
  end

  it "converts unix time to time" do
    expect(parser.unix).to eq Time.unix(1674843165)
  end

  it "converts unix time to time" do
    expect(parser.unix_ms).to eq Time.unix_ms(1674843241159)
  end

  it "converts string to color" do
    expect(parser.color).to eq Color::Red
  end

  it "converts string to color" do
    expect(parser.ncolor).to eq Color::Blue
  end
end
