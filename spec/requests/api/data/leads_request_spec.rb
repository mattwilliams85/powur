require 'spec_helper'

describe '/api/data/leads', type: :request do
  before :each do
    login_api_app
  end

  let(:lead) do
    VCR.use_cassette('zip_validation/valid') do
      create(:submitted_lead)
    end
  end
  let(:json) { json_fixture('api_data_leads') }

  def lead_update_data(overrides = {})
    data = MultiJson.decode(json)
    data.merge(overrides)
  end

  describe 'POST /' do
    def post_lead_update(overrides = {})
      data = lead_update_data(overrides)

      post api_data_leads_path,
           MultiJson.encode(data),
           api_header.merge('CONTENT_TYPE' => 'application/json')
    end

    it 'creates a lead update' do
      post_lead_update('uid' => "test.powur.com:#{lead.id}")

      expect(response.status).to eq(201)
      expect(json_body['leadUpdateId']).to be
    end

    it 'invalidates an incorrect uid prefix' do
      post_lead_update('uid' => "production.powur.com:#{lead.id}")

      expect_api_error
    end

    it 'invalidates an incorrect uid' do
      post_lead_update('uid' => "test.powur.com:#{lead.id + 1}")

      expect_api_error
    end

    it 'requires a uid' do
      post_lead_update(uid: nil)

      expect_api_error
    end
  end

  describe 'POST /batch' do
    let(:quote2) { create(:quote) }

    it 'creates a batch of lead updates' do
      data1 = lead_update_data('uid' => "test.powur.com:#{lead.id}")
      data2 = lead_update_data('uid' => "production.powur.com:#{lead.id}")

      post batch_api_data_leads_path,
           MultiJson.encode(batch: [ data1, data2 ]),
           api_header.merge('CONTENT_TYPE' => 'application/json')

      first = json_body['updates'].first
      second = json_body['updates'].second
      expect(first['providerUid']).to eq(data1['providerUid'])
      expect(second['providerUid']).to eq(data2['providerUid'])

      expect(first['error']).to_not be
      expect(second['error']).to be
    end
  end
end
