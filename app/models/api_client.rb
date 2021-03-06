class ApiClient < ActiveRecord::Base
  scope :by_credentials, ->(id, secret) { where(id: id, secret: secret) }

  has_many :tokens,
           class_name:  'ApiToken',
           inverse_of:  :client,
           foreign_key: 'client_id',
           dependent:   :destroy
end
