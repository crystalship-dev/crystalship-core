module CrShip::Core::Config
  macro define(&block)
    @@__cs_config_store : ::CrShip::Core::Config::Store? = nil

    def self.load(path : String = "config/ship.yml") : Nil
      @@__cs_config_store = ::CrShip::Core::Config::Store.from_ship_yml(path)
    end

    private def self.__cs_store : ::CrShip::Core::Config::Store
      store = @@__cs_config_store

      raise ::CrShip::Core::Config::Error.new(
        "Config: not loaded. Call #{ {{ @type }} }.load(..) during boot."
      ) unless store

      store
    end

    {{ block.body }}
  end

  macro group(name, &block)
    {% group_str = name.id.stringify %}
    {% group_const = group_str.id.camelcase %}

    struct {{ group_const }}
      def initialize(@store : ::CrShip::Core::Config::Store)
      end

      {% body = block.body %}
      {% if body.nil? %}
        {% raise "Config DSL: group #{group_str} must contain at least one `key ...`" %}
      {% end %}

      {% if body.is_a?(Expressions) %}
        {% stmts = body.expressions %}
      {% else %}
        {% stmts = [body] %}
      {% end %}

      {% for stmt in stmts %}
        {% unless stmt.class_name == "Call" && stmt.name.stringify == "key" %}
          {% raise "Config DSL: only `key :name, Type, ...` is allowed inside group #{group_str}" %}
        {% end %}

        {% args = stmt.args %}
        {% if args.size < 2 %}
          {% raise "Config DSL: key requires at least (:name, Type)" %}
        {% end %}

        {% key_sym = args[0] %}
        {% key_type = args[1].resolve %}
        {% key_str = key_sym.id.stringify %}

        {% env_node = nil %}
        {% default_node = nil %}
        {% required_node = nil %}

        {% for na in stmt.named_args %}
          {% if na.name.stringify == "env" %}
            {% env_node = na.value %}
          {% elsif na.name.stringify == "default" %}
            {% default_node = na.value %}
          {% elsif na.name.stringify == "required" %}
            {% required_node = na.value %}
          {% end %}
        {% end %}

        {% if env_node.nil? %}
          {% env_key = "CRYSTALSHIP_#{group_str.id.upcase}_#{key_str.id.upcase}" %}
        {% else %}
          {% env_key = env_node %}
        {% end %}

        {% if required_node.nil? %}
          {% required_flag = default_node.nil? %}
        {% else %}
          {% required_flag = required_node %}
        {% end %}

        def {{ key_sym.id }} : {{ key_type }}
          {% if default_node.nil? %}
            @store.fetch({{ key_type }}, {{ env_key }}, required: {{ required_flag }})
          {% else %}
            @store.fetch({{ key_type }}, {{ env_key }}, default: {{ default_node }}, required: {{ required_flag }})
          {% end %}
        end
      {% end %}
    end

    def self.{{ name.id }} : {{ group_const }}
      {{ group_const }}.new(__cs_store)
    end
  end
end
