module SirenDSL
  extend ActiveSupport::Concern

  Action = Struct.new(:name, :method, :href) do

    Field = Struct.new(:name, :type, :attributes)

    def fields
      @fields ||= []
    end

    def field(name, type, attributes = {})
      fields << Field.new(name, type, attributes) and self
    end

  end

  Link = Struct.new(:rel, :href)

  included do
    helper_method :siren, :klass, :action, :actions, :links, :link
  end

  attr_reader :json

  protected

  def siren(json)
    @json = json
  end

  def klass(*values)
    json.set! :class, values
  end

  def action(name, method, href)
    Action.new(name, method, href)
  end

  def actions(*action_list)
    json.actions action_list do |action|
      json.(action, :name)
      json.method action.method.to_s.upcase
      json.(action, :href)
      json.type 'application/json'
      json.fields action.fields do |field|
        json.(field, :name, :type)
        field.attributes.each do |key, value|
          json.set! key, value
        end if field.attributes
      end unless action.fields.empty?
    end
  end

  def links(*link_list)
    json.links link_list do |link|
      json.(link, :rel, :href)
    end
  end

  def link(rel, href)
    Link.new(rel, href)
  end
end