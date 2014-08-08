module SortAndPage
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    attr_reader :sort_options
    def sort_and_page(opts = {})
      @sort_options = opts
      self.include InstanceMethods
    end
  end

  module InstanceMethods
    def foo
      binding.pry
      raise 'foo'
    end
    # def sort_order
    #   @sort_order ||= begin
    #     key = params[:sort] && available_sorts.keys.include?(params[:sort].to_sym) ?
    #       params[:sort].to_sym : available_sorts.keys.first
    #     available_sorts[key]
    #   end
    # end

    # def limit
    #   @limit ||= params[:limit] ? params[:limit].to_i : 20
    # end

    # def page
    #   @page ||= params[:page] ? params[:page].to_i : 1
    # end

    # def total_pages
    #   @total_pages ||= begin
    #     total_count = @quotes.except(:offset, :limit, :order).count
    #     total_count / limit + (total_count % limit > 0 ? 1 : 0)
    #   end
    # end

    # def offset
    #   limit * (page - 1)
    # end
  end


end
