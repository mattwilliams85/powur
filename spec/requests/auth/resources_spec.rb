require 'spec_helper'

describe 'GET /u/resources' do
  context 'when signed in' do
    let!(:user) { login_user }

    before do
      allow(user).to receive(:full_name).and_return('Bob')
      allow_any_instance_of(Resource).to receive(:user).and_return(user)
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

describe 'get filtered resources' do
  let!(:user) { login_user }
  let!(:video_resource) { create(:resource, file_original_path: 'file.mp4') }
  let!(:document_resource) { create(:resource, file_original_path: 'file.pdf') }
  let!(:unpublished_resource) { create(:resource, is_public: false) }

  before do
    allow(user).to receive(:full_name).and_return('Bob')
    allow_any_instance_of(Resource).to receive(:user).and_return(user)
  end

  it 'returns video resource json data' do
    get resources_path(type: 'videos'), format: :json

    expect_entities_count(1)
    expect_props(
      paging: {
        'current_page' => 1,
        'item_count' => 1,
        'page_count' => 1,
        'page_size' => 50
      }
    )
    expect(JSON.parse(response.body)['entities'][0]['properties']['id']).to eq(video_resource.id)
  end

  it 'returns document resource json data' do
    get resources_path(type: 'documents'), format: :json

    expect_entities_count(1)
    expect_props(
      paging: {
        'current_page' => 1,
        'item_count' => 1,
        'page_count' => 1,
        'page_size' => 50
      }
    )
    expect(JSON.parse(response.body)['entities'][0]['properties']['id']).to eq(document_resource.id)
  end
end
