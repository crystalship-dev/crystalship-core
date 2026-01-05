require "spec"
require "../src/crystalship-core"

describe CrShip::Core::Lifecycle do
  it "runs hooks in order" do
    events = [] of String

    CrShip::Core.before_boot { events << "before" }
    CrShip::Core.on_ready { events << "ready" }
    CrShip::Core.boot { events << "boot" }

    events.should eq(["before", "boot", "ready"])
  end
end
