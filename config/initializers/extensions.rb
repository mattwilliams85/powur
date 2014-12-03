
ActiveRecord::Base.include(AddSearch)
ActiveRecord::Base.instance_eval do
  def enum_options(enum_key)
    Hash[send(enum_key).keys.map { |k| [ k, k.titleize ] }]
  end
end
