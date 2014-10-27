module SirenJson
  include ActionView::Helpers::NumberHelper

  EntityRef = Struct.new(:klass, :rel, :href) do
    def render(json)
      json.set! :class, klass
      json.rel [ rel ]
      json.href href
    end
  end

  EntityPartial = Struct.new(:path, :rel, :opts) do
    def render(json)
      json.partial!(path, opts.merge(rel: rel))
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

  attr_reader :json

  def siren(json)
    @json = json
    json.properties do
      json._message @message if @message
    end
  end

  def klass(*values)
    opts = values.last.is_a?(Hash) ? values.pop : {}
    json.set! :class, values

    json.properties do
      if values.include?(:list)
        json.paging pager.meta if paging?
        json.sorting sorter.meta if sorting?
        if filtering?
          json.filters do
            filters.keys.each do |scope|
              json.set! scope, params[scope]
            end
          end
        end
      end
      if @totals && (values.include?(:list) || opts[:totals])
        render_totals(json)
      end
    end
  end

  def entity_rel(value = nil)
    json.rel [ value || :item ]
  end

  def entities(*args)
    json.entities args do |entity|
      entity.render(json)
    end
  end

  def entity(path_or_klass, rel, opts = {})
    if opts.is_a?(String)
      EntityRef.new(path_or_klass, rel, opts)
    else
      EntityPartial.new(path_or_klass, rel, opts)
    end
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

  def self_link(path, *list)
    list.unshift(link(:self, path))
    links(*list)
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
        field_opts = { value: params[scope], required: !opts[:required].nil? }
        if opts[:options]
          field_opts[:options] = opts[:options]
        else
          reference = { url:     instance_exec(&opts[:url]),
                        value:   opts[:id],
                        display: opts[:name] }
          field_opts[:reference] = reference
        end
        if opts[:heading]
          field_opts[:heading] = t("headings.#{opts[:heading]}")
        end
        action.field(scope, :select, field_opts)
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
