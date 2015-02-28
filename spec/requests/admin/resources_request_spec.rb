require 'spec_helper'

describe 'GET /a/resources' do
  let!(:user) { login_user }

  context 'when signed in as admin' do
    before do
      create_list(:resource, 2)
      create(:resource, is_public: false)
    end

    it 'returns json data' do
      get admin_resources_path, format: :json

      expect_entities_count(3)
      expect_props(
        paging: {
          'current_page' => 1,
          'item_count' => 3,
          'page_count' => 1,
          'page_size' => 50
        }
      )
    end
  end

  context 'when signed in as regular user' do
    before do
      allow(user).to receive(:role?).with(:admin).and_return(false)
    end

    it 'returns a redirect url' do
      get admin_resources_path, format: :json

      expect(JSON.parse(response.body)).to eq({
        'redirect' => 'http://www.example.com/u/dashboard'
      })
    end
  end
end

describe 'GET /a/resources/:id' do
  let!(:user) { login_user }
  let(:resource) { create(:resource) }

  it 'returns json data' do
    get admin_resource_path(resource), format: :json

    expect_props(
      id: resource.id,
      user_id: resource.user_id,
      title: resource.title,
      description: resource.description,
      file_original_path: resource.file_original_path,
      file_type: resource.file_type,
      is_public: resource.is_public
    )
  end
end
