# crystalship-rig-core

**Crystalship Rig-Core** - fundamental shard of framework **Crystalship** (namespace: `CrShip`). It contains basic capabilities, that will be used by other *Crystalship Rigs*:
**compile-time DI** and **typed configuration**.

- Namespace: `CrShip::Rig::Core`
- License: MIT
- Status: early development (0.0.x)

## Features

### DI (compile-time container)
- `CrShip::Rig::Core::Container.resolve(T)` - resolve dependencies via constructor.
- Singleton caching on the type level.
- Hardening (compile-time checks):
  - skips `abstract` types
  - prohibits multiple `initialize`
  - requires type restriction for constructor arguments
  - allows dependencies only on `Injectable`
  
### Typed Config (DSL + ship.yml + ENV)
- Config is described via DSL and generates typed getters
- Values are taken from:
  - `ENV`
  - `config/ship.yml` -> `env:`
  - `default`
- `required: true` - raises an error if the key is missing.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crystalship-rig-core:
       github: crystal-dev/crystalship-rig-core
   ```

2. Run `shards install`

## Usage

### DI example

```crystal
require "crystalship-rig-core"

module App
  @[CrShip::Rig::Core::Component]
  class MailTransport < CrShip::Rig::Core::Injectable
  end

  @[CrShip::Rig::Core::Component]
  class EmailService < CrShip::Rig::Core::Injectable
    def initialize(@transport : App::MailTransport)
    end
  end
end

svc = CrShip::Rig::Core::Container.resolve(App::EmailService)
```

### Config example

```crystal
require "crystalship-rig-core"

module AppConfig
  include CrShip::Rig::Core::Config

  define do
    group :http do
      key :port, Int32, default: 3000
    end

    group :db do
      key :url, String, required: true
    end
  end
end

# config/ship.yml
# env:
#   CRYSTALSHIP_HTTP_PORT: "3000"
#   CRYSTALSHIP_DB_URL: "postgres://..."

AppConfig.load("config/ship.yml")

pp AppConfig.http.port  # Int32
pp AppConfig.db.url     # String (required)
```

## Development

```bash
shards install
crystal spec
crystal tool format
```

## Contributing

1. Fork it (<https://github.com/crystalship-dev/crystalship-rig-core/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT

## Contributors

- [Pavlo Kilko](https://github.com/PavloKilko) - creator and maintainer
