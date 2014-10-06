module SirenDSL
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper

  RefEntity = Struct.new(:klass, :rel, :href) do
    def render(json)
      json.set! :class, klass
      json.rel [ rel ]
      json.href href
    end
  end

  PartialEntity = Struct.new(:name, :value, :opts) do
    def render(json)
      path = opts.delete(:path) || "#{name}s/item"
      args = (opts || {}).merge(name => value)
      json.partial!(path, args)
    end
  end

  Action = Struct.new(:name, :method, :href) do
    Field = Struct.new(:name, :type, :attributes)

    def fields
      @fields ||= []
    end

    def field(name, type, attributes = {})
      fields << Field.new(name, type, attributes)
      self
    end
  end

  Link = Struct.new(:rel, :href)

  included do
    helper_method :siren, :klass, :entities, :ref_entity, :partial_entity,
                  :action, :actions, :links, :link, :entity_rel, :index_action
  end

  attr_reader :json

  protected

  def siren(json)
    @json = json
    json.properties do
      json._message @message if @message
    end
  end

  def confirm(value, args = {})
    message confirm: value.is_a?(Symbol) ? t("confirms.#{value}", args) : value
  end

  # rubocop:disable Style/TrivialAccessors
  def message(value)
    @message = value
  end

  def klass(*values)
    opts = values.last.is_a?(Hash) ? values.pop : {}
    json.set! :class, values

    json.properties do
      if values.include?(:list)
        json.paging pager.meta if paging?
        json.sorting sorter.meta if sorting?
      end
      if @totals && (values.include?(:list) || opts[:totals])
        render_totals(json)
      end
    end
  end

  def entity_rel(relationship = nil)
    json.rel [ relationship || :item ]
  end

  def entities(*args)
    json.entities args do |entity|
      entity.render(json)
    end
  end

  def ref_entity(klass, rel, href)
    RefEntity.new(klass, rel, href)
  end

  def partial_entity(name, value, opts = {})
    PartialEntity.new(name, value, opts)
  end

  def action(name, method, href)
    Action.new(name, method, href)
  end

  def actions(*action_list)
    json.actions action_list do |action|
      json.call(action, :name)
      json.method action.method.to_s.upcase
      json.call(action, :href)
      json.type 'application/json'
      json.fields action.fields do |field|
        json.call(field, :name, :type)
        field.attributes.each do |key, value|
          json.set! key, value
        end if field.attributes
      end unless action.fields.empty?
    end
  end

  def links(*link_list)
    json.links link_list do |link|
      json.call(link, :rel, :href)
    end
  end

  def link(rel, href)
    Link.new(rel, href)
  end

  def index_action(url, search = false)
    action = action(:index, :get, url)

    action.field(:search, :search, required: false) if search
    if paging?
      action.field(:page, :number,
                   value: pager[:current_page],
                   min:   1,
                   max:   pager[:page_count], required: false)
    end
    if sorting? && sorter[:sorts].size > 1
      action.field(:sort, :select,
                   options:  sorter[:sorts],
                   value:    sorter[:current_sort],
                   required: !sorter[:required].nil?)
    end
    if filtering?
      filters.each do |scope, opts|
        reference = { url:  instance_exec(&opts[:url]),
                      id:   opts[:id],
                      name: opts[:name] }
        action.field(scope, :select,
                     reference: reference,
                     value:     params[scope],
                     required:  !opts[:required].nil?)
      end
    end

    action
  end

  private

  def render_totals(json)
    @totals.each do |total|
      total[:title] ||= t("totals.#{total[:id]}")
      if total[:type] == :currency
        total[:value] = number_to_currency(total[:value])
      end
    end
    json.totals @totals
  end
end
