require 'spec_helper'

describe 'GET /u/product_invites' do
  let!(:user) { login_user }

  before do
    create(:customer, user_id: user.id)
    create(:customer)
  end

  it 'returns json data' do
    get product_invites_path, format: :json

    expect_entities_count(1)
    expect_actions('create')
    expect_props(
      paging: {
        'current_page' => 1,
        'item_count'   => 1,
        'page_count'   => 1,
        'page_size'    => 50
      }
    )
    expect_props(sent: 1)
  end
end

describe 'POST /u/product_invites' do
  let!(:user) { login_user }
  # let(:product) { create(:product) }

  let(:payload) do
    { email:      'example@example.com',
      first_name: 'Dilbert',
      last_name:  'Pickles' }
  end

  it 'creates new customer and invite' do
    expect(PromoterMailer).to receive(:product_invitation)
      .once.and_return(double(deliver_later: nil))
    post product_invites_path, payload, format: :json

    expect_props(
      status:    Customer.statuses.keys[0],
      full_name: payload[:first_name] + ' ' + payload[:last_name],
      email:     payload[:email])
  end

  context 'when customer already exists' do
    let!(:customer) { create(:customer, email: payload[:email]) }

    it 'returns error' do
      post product_invites_path, payload, format: :json

      expect_alert_error
    end
  end
end
