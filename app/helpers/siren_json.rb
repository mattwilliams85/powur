module SirenJson
  include ActionView::Helpers::NumberHelper

  class EntityRef
    pattr_initialize :klass, :rel, :href

    def render(json)
      json.set! :class, @klass
      json.rel [ @rel ]
      json.href @href
    end
  end

  class EntityPartial
    pattr_initialize :path, :rel, :opts

    def render(json)
      json.partial!(@path, @opts.merge(rel: @rel))
    end
  end

  class Action
    class Field
      vattr_initialize :name, :type, :attributes
    end
    vattr_initialize :name, :method, :href

    def fields
      @fields ||= []
    end

    def field(fname, type, attributes = {})
      fields << Field.new(fname, type, attributes)
      self
    end
  end

  class Link
    vattr_initialize :rel, :href
  end

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
      if values.include?(:list) && list_query_applied?
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
      sort_options = keys_to_options(sorter[:sorts])
      action.field(:sort, :select,
                   options:  Hash[sort_options],
                   value:    sorter[:current_sort],
                   required: !sorter[:required].nil?)
    end
    if filtering?
      filters.each do |scope, opts|
        if opts[:fields]
          opts[:fields].each do |key, value|
            filter_field(action, "#{scope}[#{key}]", value)
          end
        else
          filter_field(action, scope, opts)
        end
      end
    end

    action
  end

  private

  def filter_field(action, scope, opts)
    field_opts = { value: params[scope], required: !!opts[:required] }
    if opts[:options]
      options = if opts[:options].is_a?(Array)
        keys_to_options(opts[:options])
      elsif opts[:options].is_a?(Hash)
        opts[:options]
      else
        instance_exec(&opts[:options])
      end
      field_opts[:options] = options
    else
      reference = { url:     instance_exec(&opts[:url]),
                    value:   opts[:id],
                    display: opts[:name] }
      field_opts[:reference] = reference
    end
    if opts[:heading]
      field_opts[:label] = t("labels.#{opts[:heading]}", 
                             default: opts[:heading].to_s.titleize)
    end

    action.field(scope, :select, field_opts)
  end

  def keys_to_options(keys)
    Hash[keys.map { |k| [ k, t("labels.#{k}", default: k.to_s.titleize) ] }]
  end

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
