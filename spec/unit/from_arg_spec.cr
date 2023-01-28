require "../spec_helper"

Spectator.describe "ArgParser from_arg" do
  it "should parse a union" do
    expect(Union(String, Nil).from_arg("foo")).to eq("foo")
  end
end
