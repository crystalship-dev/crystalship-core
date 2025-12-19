require "spec"
require "../src/crystalship/rig/core"

describe CrShip::Rig::Core do
  it "has a version" do
    CrShip::Rig::Core::VERSION.should_not be_empty
  end
end
