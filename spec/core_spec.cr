require "spec"
require "../src/crystalship-core"

describe CrShip::Core do
  it "has a version" do
    CrShip::Core::VERSION.should_not be_empty
  end
end
