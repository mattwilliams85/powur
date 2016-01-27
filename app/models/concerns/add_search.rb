module AddSearch
  extend ActiveSupport::Concern

  SEARCH = '
    :q %% %{table}.first_name or
    :q %% %{table}.last_name or
    %{table}.email ilike :like'

  included do
  end

  class_methods do
    def add_search(*relations)
      relations.each do |relation|
        if relation.respond_to?(:each)
          _add_multi_table_search(relation)
        else
          _add_single_table_search(relation)
        end
      end
    end

    private

    def _get_table_name(relation)
      association = reflect_on_association(relation)
      unless association
        fail ArgumentError, "Association :#{relation} not found"
      end

      association.table_name
    end

    def _add_single_table_search(relation)
      sql = SEARCH % { table: _get_table_name(relation) }

      scope "#{relation}_search".to_sym, lambda { |term|
        includes(relation).references(relation)
          .where(sql, q: term, like: "%#{term}%")
      }
    end

    def _add_multi_table_search(relations)
      search_scopes = []
      search_scopes << method('search') if relations.delete(:self)
      relations.each { |r| search_scopes << method("#{r}_search") }

      scope "#{relations.join('_')}_search".to_sym, lambda { |term|
        includes(*relations).references(*relations)
          .where.any_of(*search_scopes.map { |s| s.call(term) })
      }
    end
  end
end
