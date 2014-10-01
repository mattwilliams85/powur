module ListQuery
  extend ActiveSupport::Concern

  included do
    attr_reader :list_query

    after_action :apply_list_query_options, only: [ :index ]
  end

  module ClassMethods
    def page(opts = {})
    end

    def sort(opts = {})
    end

    def filter(scope, opts = {})
    end
  end

  def apply_list_query_options
  end

end







