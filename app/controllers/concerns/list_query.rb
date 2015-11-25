module ListQuery
  extend ActiveSupport::Concern

  included do
    helper_method :paging?, :pager, :sorting?, :sorter, :filtering?, :filters,
                  :item_totals, :aggregator, :aggregating?, :list_query_applied?
  end

  module ClassMethods
    def list_query_opts
      @list_query_opts ||= {}
    end

    def page(opts = {})
      list_query_opts[:paging_opts] = opts
    end

    def sort(opts = {})
      list_query_opts[:sorting_opts] = opts
    end

    def filter(scope, opts = {})
      if opts[:required] && opts[:default].nil?
        fail ArgumentError,
             "The filter #{scope} is required but no default was supplied"
      end
      has_scope scope, opts.delete(:scope_opts)
      list_query_opts[:filters] ||= {}
      opts.reverse_merge!(id: :id, name: :name)
      list_query_opts[:filters][scope] = opts
    end

    def item_totals(*args)
      list_query_opts[:item_totals] = args
    end

    def list_query(query_var)
      list_query_opts[:query_var] = query_var
    end
  end

  class InvalidRequest < StandardError; end

  def list_opts
    self.class.list_query_opts
  end

  def paging?
    !list_opts[:paging_opts].nil?
  end

  def pager
    @pager ||= Pager.new(params, list_opts[:paging_opts])
  end

  def sorting?
    !list_opts[:sorting_opts].nil?
  end

  def sorter
    @sorter ||= Sorter.new(params, list_opts[:sorting_opts])
  end

  def filters
    @filters ||= begin
      filter_list = list_opts[:filters] || {}
      filter_list.each do |key, opts|
        if opts[:required]
          params[key] ||= instance_exec(&opts[:default])
          filter_list.delete(key) if params[key].nil?
        end
      end
      list_opts[:filters]
    end
  end

  def filtering?
    !filters.nil? && !filters.empty?
  end

  def item_totals
    @item_totals ||= {}
  end

  def aggregator
    @aggregator ||= Aggregator.new(params, list_opts[:item_totals])
  end

  def aggregating?
    !list_opts[:item_totals].nil? && aggregator.requested?
  end

  def list_query_applied?
    !@list_query_klass.nil?
  end

  def apply_list_query_options(query)
    @list_query_klass = true
    query = apply_scopes(query) if filtering?
    query = aggregator.apply(query) if aggregating?
    query = sorter.apply(query) if sorting?
    query = pager.apply(query) if paging?
    query
  rescue InvalidRequest => e
    error!(e.message)
  end

  class Pager
    attr_reader :params, :opts, :query

    def initialize(params, opts = {})
      @params = params
      @opts = opts.reverse_merge(max_limit: 50)
    end

    def apply(query)
      @query = query.limit(limit).offset(offset)
    end

    def meta
      @meta ||= {
        page_count:   page_count,
        item_count:   item_count,
        current_page: current_page,
        page_size:    limit }
    end

    def [](key)
      meta[key]
    end

    private

    def limit
      @limit ||= begin
        max = opts[:max_limit]
        params[:limit] ? [ params[:limit].to_i, max ].min : max
      end
    end

    def current_page
      @current_page ||= params[:page] ? params[:page].to_i : 1
      @current_page.zero? ? 1 : @current_page
    end

    def offset
      limit * (current_page - 1)
    end

    def item_count
      @item_count ||= query.except(:offset, :limit, :order).length
    end

    def page_count
      @page_count ||= begin
        value = item_count / limit + (item_count % limit > 0 ? 1 : 0)
        value.zero? ? 1 : value
      end
    end
  end

  class Sorter
    attr_reader :params, :opts

    def initialize(params, opts = {})
      @params = params
      @opts = { sorts:     opts,
                secondary: opts.delete(:secondary) || { id: :asc } }
    end

    def apply(query)
      query = query.order(sort_order)
      query = query.order(opts[:secondary]) if opts[:secondary]
      query
    end

    def meta
      @meta ||= {
        sorts:        opts[:sorts].keys,
        current_sort: sort_key }
    end

    def [](key)
      meta[key]
    end

    private

    def keys
      opts[:sorts].keys
    end

    def sort_key
      @sort_key ||= begin
        key = params[:sort] && params[:sort].to_sym
        key = keys.first if key.nil? || !keys.include?(key)
        key
      end
    end

    def sort_order
      opts[:sorts][sort_key]
    end
  end

  class Aggregator
    attr_reader :params, :available

    def initialize(params, available)
      @params = params
      @available = available
    end

    def apply(query)
      selected.each do |scope|
        query = query.merge(query.model.send(scope))
      end
      query
    end

    def selected
      @selected ||= begin
        requested = params[:item_totals].split(',').map(&:to_sym)
        (available || {}).select { |key, _| requested.include?(key) }
      end
    end

    def requested?
      params[:item_totals].present? && selected.size > 0
    end
  end
end
