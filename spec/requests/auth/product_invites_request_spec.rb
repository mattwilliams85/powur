require 'spec_helper'

describe 'GET /u/product_invites' do
  let!(:user) { login_user }

  before do
    create_list(:product_invite, 2)
  end

  it 'returns json data' do
    get product_invites_path, format: :json

    expect_entities_count(2)
    expect_props(
      paging: {
        'current_page' => 1,
        'item_count'   => 2,
        'page_count'   => 1,
        'page_size'    => 50
      }
    )
  end
end

describe 'POST /u/product_invites' do
  let!(:user) { login_user }
  let(:product) { create(:product) }

  let(:payload) do
    { product_id: product.id,
      email:      'example@example.com',
      first_name: 'Dilbert',
      last_name:  'Pickles' }
  end

  it 'creates new customer and invite' do
    post product_invites_path, payload, format: :json

    expect_props(
      status:     ProductInvite.statuses.keys[0],
      product_id: payload[:product_id],
      customer:   {
        'full_name' => payload[:first_name] + ' ' + payload[:last_name],
        'email'     => payload[:email]
      }
    )
  end

  context 'when customer already exists' do
    let!(:customer) { create(:customer, email: payload[:email]) }

    it 'returns error' do
      post product_invites_path, payload, format: :json

      expect_alert_error
    end
  end
end
