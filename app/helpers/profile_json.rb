class ProfileJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :users, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :profile

    entity_rel(rel) if rel
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :user
  end

  def detail_properties(user = @item)
    list_item_properties

    json.properties do
      json.call(user, :first_name, :last_name, :email, :phone,
                :bio, :avatar, :avatar_file_name, :address,
                :city, :state, :zip)
      json.avatar do
        [ :thumb, :medium, :large ].each do |key|
          json.set! key, user.avatar.url(key)
        end
      end if user.avatar?
    end
  end

  def update_action(profile_path, user)
    actions \
      action(:update, :patch, profile_path)
      .field(:first_name, :text, value: user.first_name)
      .field(:last_name, :text, value: user.last_name)
      .field(:email, :email, value: user.email)
      .field(:phone, :text, value: user.phone)
      .field(:address, :text, value: user.address)
      .field(:city, :text, value: user.city)
      .field(:state, :text, value: user.state)
      .field(:zip, :text, value: user.zip)
      .field(:provider, :text, value: user.provider)
      .field(:monthly_bill, :text, value: user.monthly_bill)
      .field(:bio, :text, value: user.bio)
      .field(:twitter_url, :text, value: user.twitter_url)
      .field(:linkedin_url, :text, value: user.linkedin_url)
      .field(:facebook_url, :text, value: user.facebook_url)
  end
end
