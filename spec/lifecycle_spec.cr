require "spec"
require "../src/crystalship-rig-core"

describe CrShip::Rig::Core::Lifecycle do
  it "runs hooks in order" do
    events = [] of String

    CrShip::Rig::Core.before_boot { events << "before" }
    CrShip::Rig::Core.on_ready { events << "ready" }
    CrShip::Rig::Core.boot { events << "boot" }

    events.should eq(["before", "boot", "ready"])
  end
end
