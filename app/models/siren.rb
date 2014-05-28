class Siren

  attr_accessor :klasses
  attr_reader :entity, :klass, :properties

  def initialize(entity, properties = {})
    @entity, @properties = entity, properties
    @klass = properties.delete(:klass) || 
      (object_entity? ? @entity.class.name.downcase.to_sym : @entity)

    if list_entity?
      self.klasses += [ :list, "#{@klass}s" ]
    else
      self.klasses << @klass
    end
  end

  Action = Struct.new(:name, :method, :href) do
    Field = Struct.new(:name, :type)

    def fields
      @fields ||= []
    end

    def field(name, type)
      fields << Field.new(name, type) and self
    end
  end

  def klasses
    @klasses ||= []
  end

  def object_entity?
    !@entity.is_a?(Symbol)
  end

  def list_entity?
    object_entity? && entity.respond_to?(:each)
  end

  def has_properties?
    object_entity? || !properties.empty?
  end

  def entity_partial
    "#{klass}s/#{klass}"
  end

  def actions
    @actions ||= []
  end

  def action(name, method, href)
    a = Action.new(name, method, href)
    (actions << a).last
  end

end
