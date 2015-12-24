require 'spec_helper'

describe '/customers/:customer_code' do
  describe '#show' do
    let(:code) { 'qwerty' }
    let(:user) { create(:user) }
    let!(:lead) { create(:lead, code: code, user: user) }

    it 'returns customer data' do
      get customer_path(lead.code), format: :json

      expect_200
      expect_props(first_name: lead.first_name)
      expect_actions('validate_zip')
    end

    it 'updates last viewed at field' do
      lead.update_attribute(:last_viewed_at, Time.zone.now - 1.month)
      get customer_path(lead.code), format: :json

      expect_200
      expect(lead.reload.last_viewed_at)
        .to be_within(1.second).of(Time.zone.now)
    end
  end
end
