require "spec"
require "../src/crystalship-core"

module TestDI
  @[CrShip::Core::Component]
  class MailTransport < CrShip::Core::Injectable
  end

  @[CrShip::Core::Component]
  class EmailService < CrShip::Core::Injectable
    getter transport : TestDI::MailTransport

    def initialize(@transport : TestDI::MailTransport)
    end
  end
end

describe CrShip::Core::Container do
  it "resolves nested dependencies" do
    svc = CrShip::Core::Container.resolve(TestDI::EmailService)
    svc.transport.should be_a(TestDI::MailTransport)
  end

  it "caches singletons per type" do
    a = CrShip::Core::Container.resolve(TestDI::MailTransport)
    b = CrShip::Core::Container.resolve(TestDI::MailTransport)
    a.object_id.should eq(b.object_id)
  end
end
