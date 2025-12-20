require "../src/crystalship-rig-core"

module TestDI
  @[CrShip::Rig::Core::Component]
  class MailTransport < CrShip::Rig::Core::Injectable
  end

  @[CrShip::Rig::Core::Component]
  class EmailService < CrShip::Rig::Core::Injectable
    getter transport : TestDI::MailTransport

    def initialize(@transport : TestDI::MailTransport)
    end
  end
end

describe CrShip::Rig::Core::Container do
  it "resolves nested dependencies" do
    svc = CrShip::Rig::Core::Container.resolve(TestDI::EmailService)
    svc.transport.should be_a(TestDI::MailTransport)
  end

  it "caches singletons per type" do
    a = CrShip::Rig::Core::Container.resolve(TestDI::MailTransport)
    b = CrShip::Rig::Core::Container.resolve(TestDI::MailTransport)
    a.object_id.should eq(b.object_id)
  end
end
