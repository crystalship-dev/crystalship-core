module CrShip::Core::Container
  def self.resolve(type : T.class) : T forall T
    {% unless T < CrShip::Core::Injectable %}
      {% raise "DI: #{T} must inherit from CrShip::Core::Injectable to be resolvable" %}
    {% else %}
      {% key = T.name.stringify.gsub(/::/, "__") %}
      self.__resolve_{{ key.id }}
    {% end %}
  end

  macro finished
    {% for t in CrShip::Core::Injectable.all_subclasses %}
      {% if t.abstract? %}
        {% next %}
      {% end %}

      {% key = t.name.stringify.gsub(/::/, "__") %}

      @@__singleton_{{ key.id }} : {{ t }}? = nil

      def self.__resolve_{{ key.id }} : {{ t }}
        @@__singleton_{{ key.id }} ||= begin
          {% inits = t.methods.select { |method| method.name == "initialize" } %}

          {% if inits.nil? %}
            {% init = nil %}
          {% else %}
            {% if inits.size > 1 %}
              {% raise "DI: #{t} has multiple initialize overloads. Only one initialize is supported." %}
            {% end %}

            {% init = inits.first %}
          {% end %}

          {% if init && init.args.size > 0 %}
            {{ t }}.new(
              {% for arg in init.args %}
                {% unless arg.restriction %}
                  {% raise "DI: #{t}#initialize arg '#{arg.name}' must have a type restriction (e.g. : SomeService)" %}
                {% end %}

                {% dep = arg.restriction.resolve %}

                {% unless dep < CrShip::Core::Injectable %}
                  {% raise "DI: #{t} depends on #{dep}, which is not Injectable. Only Injectable dependencies are supported." %}
                {% end %}

                self.resolve({{ dep }}),
              {% end %}
            )
          {% else %}
            {{ t }}.new
          {% end %}
        end
      end
    {% end %}
  end
end
