module SortAndPage
  extend ActiveSupport::Concern

  included do
    helper_method :paging, :paging?, :page!, :filtering?, :filters
    include InstanceMethods
  end

  module ClassMethods
    attr_reader :paging_options, :filters

    def sort_and_page(opts)
      @paging_options = opts
    end

    def filters
      @filters ||= {}
    end

    def filter(scope, opts)
      has_scope scope, opts.delete(:scope_opts)
      filters[scope] = opts.reverse_merge(id: :id, name: :name)
    end
  end

  module InstanceMethods
    def paging
      @paging ||= Paging.new(params, self.class.paging_options)
    end

    def paging?
      @paging && @paging.used?
    end

    def page!(query)
      paging.sort_and_page(query)
    end

    def filters
      self.class.filters
    end

    def filtering?
      !filters.empty?
    end

    class Paging
      attr_reader :params, :opts

      def initialize(params, opts)
        @params = params
        @opts = opts.reverse_merge(max_limit: 50, secondary: { id: :asc })
      end

      def sort_key
        @sort_key ||= begin
          key = params[:sort] && params[:sort].to_sym
          key.nil? || !opts[:available_sorts].keys.include?(key) ?
            key = opts[:available_sorts].keys.first :
            key
        end
      end

      def sort_order
        opts[:available_sorts][sort_key]
      end

      def limit
        @limit ||= params[:limit] ? 
          [ params[:limit].to_i, opts[:max_limit] ].min : opts[:max_limit]
      end

      def page
        @page ||= params[:page] ? params[:page].to_i : 1
      end

      def offset
        limit * (page - 1)
      end

      def used?
        @used ||= false
      end

      def sort_and_page(query)
        @used = true
        @items = query.order(sort_order).order(opts[:secondary]).
          limit(limit).offset(offset)
      end
  
      def item_count
        @item_count ||= @items.except(:offset, :limit, :order).count
      end
  
      def page_count
        @page_count ||= begin
          value = item_count / limit + (item_count % limit > 0 ? 1 : 0)
          value.zero? ? 1 : value
        end
      end

      def meta
        @meta ||= {
          page_count:   page_count,
          item_count:   item_count,
          current_page: page,
          page_size:    limit,
          sorts:        opts[:available_sorts].keys,
          current_sort: sort_key }
      end

      def [](key)
        meta[key]
      end
    end

  end

end
