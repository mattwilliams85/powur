require 'spec_helper'

describe 'GET /u/resources' do
  context 'when signed in' do
    let!(:user) { login_user }

    before do
      create_list(:resource, 2)
      create(:resource, is_public: false)
    end

    it 'returns json data' do
      get resources_path, format: :json

      expect_entities_count(2)
      expect_props(
        paging: {
          'current_page' => 1,
          'item_count' => 2,
          'page_count' => 1,
          'page_size' => 50
        }
      )
    end
  end

  context 'when signed out' do
    it 'returns a redirect url' do
      get resources_path, format: :json

      expect(JSON.parse(response.body)).to eq({
        'redirect' => '/'
      })
    end
  end
end
