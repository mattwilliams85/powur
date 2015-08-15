
ActiveRecord::Base.include(AddSearch)
ActiveRecord::Base.include(TypedStoreAccessor)

ActiveRecord::Base.instance_eval do
  def enum_options(enum_key)
    Hash[send(enum_key).keys.map { |k| [ k, k.titleize ] }]
  end
end

module ResetTableAutoId
  extend ActiveSupport::Concern

  class_methods do
    def reset_auto_id
      sql = "select id from #{table_name} order by id desc limit 1;"
      result = connection.execute(sql)
      return unless result.any?
      next_id = result.first['id'].to_i + 1
      sql = "alter sequence #{table_name}_id_seq restart with #{next_id}"
      connection.execute(sql)
    end
  end
end

ActiveRecord::Base.send(:include, ResetTableAutoId)
