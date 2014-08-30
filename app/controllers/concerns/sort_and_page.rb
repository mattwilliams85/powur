module SortAndPage
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    attr_reader :sort_and_page_options

    def sort_and_page(opts = {})
      @sort_and_page_options = opts
      self.include InstanceMethods

      self.instance_eval do
        helper_method :total_pages, :available_sorts
      end
    end
  end

  module InstanceMethods
    def _sp_opts
      self.class.sort_and_page_options
    end
    
    def available_sorts
      _sp_opts[:available_sorts]
    end

    def sort_order
      @sort_order ||= begin
        key = params[:sort] && params[:sort].to_sym
        if key.nil? || !available_sorts.keys.include?(key)
          key = available_sorts.keys.first
        end
        available_sorts[key]
      end
    end

    def limit
      @limit ||= params[:limit] ? params[:limit].to_i : (_sp_opts[:max_limit] || 50)
    end

    def sort_and_page(query)
      @items = query.order(sort_order).limit(limit).offset(offset)
    end

    def item_count
      @item_count ||= @items.except(:offset, :limit, :order).count
    end

    def page
      @page ||= params[:page] ? params[:page].to_i : 1
    end

    def total_pages
      @total_pages ||= begin
        value = item_count / limit + (item_count % limit > 0 ? 1 : 0)
        value.zero? ? 1 : value
      end
    end

    def offset
      limit * (page - 1)
    end
  end


end
