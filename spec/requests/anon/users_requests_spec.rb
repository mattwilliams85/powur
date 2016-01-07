require 'spec_helper'

describe 'GET /users/:id' do
  let(:user) { create(:user) }

  it 'increments solar landing views count' do
    expect(user.solar_landing_views_count).to be_nil
    get anon_user_path(user), format: :json
    expect(user.reload.solar_landing_views_count).to eq('1')
    get anon_user_path(user), format: :json
    expect(user.reload.solar_landing_views_count).to eq('2')
  end
end
