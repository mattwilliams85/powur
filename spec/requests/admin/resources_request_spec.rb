require 'spec_helper'

describe 'GET /a/resources' do
  let!(:user) { login_user }

  context 'when signed in as admin' do
    before do
      allow(user).to receive(:full_name).and_return('Bob')
      allow_any_instance_of(Resource).to receive(:user).and_return(user)
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

  before do
    allow(user).to receive(:full_name).and_return('Bob')
    allow_any_instance_of(Resource).to receive(:user).and_return(user)
  end

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

describe 'PUT /a/resources/:id' do
  let!(:user) { login_user }
  let(:resource) { create(:resource) }

  let(:payload) {
    {
      title: 'New Title',
      description: 'New Description',
      file_original_path: 'http://www.newurl.com/file.mp4'
    }
  }

  it 'returns json data' do
    put admin_resource_path(resource), payload.merge(format: :json)

    expect(response.code).to eq('200')
    saved_resource = Resource.last
    expect(saved_resource.title).to eq(payload[:title])
    expect(saved_resource.description).to eq(payload[:description])
    expect(saved_resource.file_original_path).to eq(payload[:file_original_path])
  end

  it 'does not update protected attributes' do
    put admin_resource_path(resource), payload.merge(user_id: 12345, format: :json)

    expect(response.code).to eq('200')
    saved_resource = Resource.last
    expect(saved_resource.user_id).to eq(resource.user_id)
  end
end
