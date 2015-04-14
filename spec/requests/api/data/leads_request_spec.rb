require 'spec_helper'

describe '/api/data/leads', type: :request do
  before :each do
    login_api_user
  end

  let(:quote) { create(:quote) }
  let(:json) { json_fixture('api_data_leads') }

  describe 'POST /', type: :request do
    def post_lead_update(overrides = {})
      data = MultiJson.decode(json)
      data.merge!(overrides)

      post api_data_leads_path,
           MultiJson.encode(data),
           api_header.merge('CONTENT_TYPE' => 'application/json')
    end

    it 'creates a lead update' do
      post_lead_update('uid' => "test.powur.com:#{quote.id}")

      expect(response.status).to eq(201)
      expect(json_body['leadUpdateId']).to be
    end

    it 'invalidates an incorrect uid prefix' do
      post_lead_update(uid: "production.powur.com:#{quote.id}")

      expect_api_error
    end

    it 'invalidates an incorrect uid' do
      post_lead_update(uid: "test.powur.com:#{quote.id+1}")

      expect_api_error
    end

    it 'requires a uid' do
      post_lead_update(uid: nil)

      expect_api_error
    end
  end
end
