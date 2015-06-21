class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  belongs_to :customer

  enum status: [ :incomplete, :ready_to_submit, :ineligible_location,
                 :submitted, :in_progress, :won, :lost, :on_hold ]


end
