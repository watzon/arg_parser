require "./spec_helper"

Spectator.describe ArgParser do
  context "supported arguments" do
    let(args) { ["--name", "John Doe", "--age", "32", "--height", "163.2", "--is_human", "true", "--website", "https://example.com", "--id", "39aacd14-9e1b-11ed-91ad-b44506ca30d5"] }
    let(parser) { TestSupportedArgs.new(args) }

    it "parses name" do
      expect(parser.name).to eq("John Doe")
    end

    it "parses age" do
      expect(parser.age).to be_a(Int32)
      expect(parser.age).to eq(32)
    end

    it "parses height" do
      expect(parser.height).to be_a(Float64)
      expect(parser.height).to eq(163.2)
    end

    it "parses is_human" do
      expect(parser.is_human).to be_a(Bool)
      expect(parser.is_human).to eq(true)
    end

    it "parses website" do
      expect(parser.website).to be_a(URI)
      expect(parser.website.to_s).to eq("https://example.com")
    end

    it "parses id" do
      expect(parser.id).to be_a(UUID)
      expect(parser.id.to_s).to eq("39aacd14-9e1b-11ed-91ad-b44506ca30d5")
    end
  end
end
