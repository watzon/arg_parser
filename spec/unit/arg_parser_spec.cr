require "../spec_helper"

Spectator.describe ArgParser do
  let(args) { ["--name", "John Doe", "--age", "32", "--height", "163.2", "--is_human", "--website", "https://example.com", "--id", "39aacd14-9e1b-11ed-91ad-b44506ca30d5"] }
  let(parser) { TestSupportedArgs.new(args) }

  it "parses string values" do
    expect(parser.name).to eq("John Doe")
  end

  it "parses int32 values" do
    expect(parser.age).to be_a(Int32)
    expect(parser.age).to eq(32)
  end

  it "parses float64 value" do
    expect(parser.height).to be_a(Float64)
    expect(parser.height).to eq(163.2)
  end

  it "parses boolean values" do
    expect(parser.is_human).to be_a(Bool)
    expect(parser.is_human).to eq(true)
  end

  it "parses uri values" do
    expect(parser.website).to be_a(URI)
    expect(parser.website.to_s).to eq("https://example.com")
  end

  it "parses uuid values" do
    expect(parser.id).to be_a(UUID)
    expect(parser.id.to_s).to eq("39aacd14-9e1b-11ed-91ad-b44506ca30d5")
  end
end
