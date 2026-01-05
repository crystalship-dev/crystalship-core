require "yaml"

module CrShip::Core::Config
  class Store
    @ship_env : Hash(String, String)

    def initialize(@ship_env : Hash(String, String))
    end

    def self.from_ship_yml(path : String) : self
      env_map = {} of String => String

      return new(env_map) unless File.exists?(path)

      root = YAML.parse(File.read(path))
      if env_any = root["env"]
        env_any.as_h.each do |k_any, v_any|
          key = k_any.as_s
          val =
            v_any.as_s? ||
              v_any.as_i64?.try(&.to_s) ||
              v_any.as_bool?.try(&.to_s) ||
              v_any.raw.to_s
          env_map[key] = val
        end
      end

      new(env_map)
    end

    def fetch(type : T.class, env_key : String, default : T? = nil, required : Bool = false) : T forall T
      raw = ENV[env_key]? || @ship_env[env_key]?

      if raw.nil?
        return default.not_nil! if default
        raise Error.new("Config: missing required #{env_key}") if required
        raise Error.new("Config: missing #{env_key} and no default/required flag")
      end

      cast(T, raw, env_key)
    end

    private def cast(type : T.class, raw : String, env_key : String) : T forall T
      {% if T == String %}
        raw
      {% elsif T == Int32 %}
        raw.to_i
      {% elsif T == Int64 %}
        raw.to_i64
      {% elsif T == Bool %}
        case raw.downcase
        when "1", "true", "yes", "y", "on"  then true
        when "0", "false", "no", "n", "off" then false
        else
          raise Error.new("Config: #{env_key} must be bool-like (true/false/1/0). got: #{raw}")
        end
      {% elsif T == Float64 %}
        raw.to_f64
      {% else %}
        {% raise "Config: unsupported type #{T}. Add cast branch in Store#cast." %}
      {% end %}
    rescue e
      raise Error.new("Config: cannot parse #{env_key} as #{T}: #{e.message}")
    end
  end
end
