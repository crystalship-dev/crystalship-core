require "spec"
require "../src/crystalship-core"

module TestConfig
  include CrShip::Core::Config

  define do
    group :http do
      key :port, Int32, default: 3000
    end

    group :db do
      key :url, String, required: true
    end
  end
end

describe "CrShip::Core::Config" do
  it "uses ENV over ship.yml env map" do
    path = "spec/tmp_ship.yml"
    File.write(path, <<-YML)
      env:
        CRYSTALSHIP_HTTP_PORT: "1111"
      YML

    prev = ENV["CRYSTALSHIP_HTTP_PORT"]?
    ENV["CRYSTALSHIP_HTTP_PORT"] = "2222"

    TestConfig.load(path)
    TestConfig.http.port.should eq(2222)
  ensure
    if prev
      ENV["CRYSTALSHIP_HTTP_PORT"] = prev
    else
      ENV.delete("CRYSTALSHIP_HTTP_PORT")
    end

    path = path.not_nil!

    File.delete(path) if File.exists?(path)
  end

  it "falls back to ship.yml env map when ENV is missing" do
    path = "spec/tmp_ship.yml"

    File.write(path, <<-YML)
      env:
        CRYSTALSHIP_HTTP_PORT: "3333"
      YML

    prev = ENV["CRYSTALSHIP_HTTP_PORT"]?
    ENV.delete("CRYSTALSHIP_HTTP_PORT")

    TestConfig.load(path)
    TestConfig.http.port.should eq(3333)
  ensure
    if prev
      ENV["CRYSTALSHIP_HTTP_PORT"] = prev
    end

    path = path.not_nil!

    File.delete(path) if File.exists?(path)
  end

  it "raises for missing required keys" do
    path = "spec/tmp_ship.yml"
    File.write(path, "env: {}\n")

    prev = ENV["CRYSTALSHIP_DB_URL"]?
    ENV.delete("CRYSTALSHIP_DB_URL")

    TestConfig.load(path)
    expect_raises(CrShip::Core::Config::Error) do
      TestConfig.db.url
    end
  ensure
    if prev
      ENV["CRYSTALSHIP_DB_URL"] = prev
    end

    path = path.not_nil!

    File.delete(path) if File.exists?(path)
  end
end
