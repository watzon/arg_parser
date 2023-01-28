require "../spec_helper"

Spectator.describe "ArgParser validators" do
  let(valid_args) { ["positional stuff", "--first_name", "John", "--age", "32"] }
  let(invalid_args) { ["positional stuff", "--first_name", "John^", "--last_name", "Doe1", "--age", "101"] }

  context "valid arguments" do
    it "should not raise an error" do
      expect { TestValidators.new(valid_args) }.not_to raise_error
    end

    it "should set the name" do
      opts = TestValidators.new(valid_args)
      expect(opts.first_name).to eq("John")
    end

    it "should set the age" do
      opts = TestValidators.new(valid_args)
      expect(opts.age).to eq(32)
    end
  end

  context "invalid arguments" do
    it "should raise an error" do
      expect { TestValidators.new(invalid_args) }.to raise_error(ArgParser::ValidationError)
    end
  end
end
