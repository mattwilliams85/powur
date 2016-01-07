require 'spec_helper'

describe 'POST /leads' do
  let(:user) { create(:user) }
  let!(:product) { create(:product) }
  let(:lead_data) do
    { user_id:        user.id,
      first_name:     'Senor',
      last_name:      'Pomodoro',
      email:          'test@example.com',
      phone:          '123',
      address:        '123 Main St',
      city:           'Portland',
      state:          'OR',
      zip:            '12345',
      call_consented: true }
  end

  before do
    allow_any_instance_of(Lead).to receive(:valid_phone?).and_return(true)
    allow_any_instance_of(Lead)
      .to receive(:validate_data_status).and_return(true)
  end

  it 'increments solar landing leads count' do
    expect(user.solar_landing_leads_count).to eq(0)
    post anon_leads_path, lead_data, format: :json
    expect(user.reload.solar_landing_leads_count).to eq(1)
    post anon_leads_path, lead_data, format: :json
    expect(user.reload.solar_landing_leads_count).to eq(2)
  end
end
