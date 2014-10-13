module ListQuery
  extend ActiveSupport::Concern

  included do
    helper_method :paging?, :pager, :sorting?, :sorter, :filtering?, :filters
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

    def list_query(query_var)
      list_query_opts[:query_var] = query_var
    end
  end

  def paging?
    !self.class.list_query_opts[:paging_opts].nil?
  end

  def pager
    @pager ||= Pager.new(params, self.class.list_query_opts[:paging_opts])
  end

  def sorting?
    !self.class.list_query_opts[:sorting_opts].nil?
  end

  def sorter
    @sorter ||= Sorter.new(params, self.class.list_query_opts[:sorting_opts])
  end

  def filters
    @filters ||= begin
      filter_list = self.class.list_query_opts[:filters] || {}
      filter_list.each do |key, opts|
        if opts[:required]
          params[key] ||= instance_exec(&opts[:default])
          filter_list.delete(key) if params[key].nil?
        end
      end
      self.class.list_query_opts[:filters]
    end
  end

  def filtering?
    !filters.nil? && !filters.empty?
  end

  def apply_list_query_options(query)
    query = pager.apply(query) if paging?
    query = sorter.apply(query) if sorting?
    query = apply_scopes(query) if filtering?
    query
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
    end

    def offset
      limit * (current_page - 1)
    end

    def item_count
      @item_count ||= query.except(:offset, :limit, :order).count
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

    def sort_key
      @sort_key ||= begin
        key = params[:sort] && params[:sort].to_sym
        if key.nil? || !opts[:sorts].keys.include?(key)
          key = opts[:sorts].keys.first
        end
        key
      end
    end

    def sort_order
      opts[:sorts][sort_key]
    end
  end
end
