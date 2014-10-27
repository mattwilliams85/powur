class UserOverride < ActiveRecord::Base
  enum kind: { active: 1, pay_as_rank: 2, unqualified: 3 }

  store_accessor :data, :rank

  belongs_to :user
end