
ActiveRecord::Base.include(AddSearch)
ActionController::Base.include(SortAndPage)
ActiveRecord::Base.instance_eval do
  def enum_options(enum_key)
    Hash[self.send(enum_key).keys.map { |k| [ k, k.titleize ] }]
  end
end
