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

describe 'GET /u/resources/videos' do
  let!(:user) { login_user }
  let!(:video_resource) { create(:resource, file_type: 'video/mp4') }
  let!(:document_resource) { create(:resource, file_type: 'application/pdf') }
  let!(:unpublished_resource) { create(:resource, is_public: false) }

  it 'returns json data' do
    get videos_resources_path, format: :json

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
end

describe 'GET /u/resources/documents' do
  let!(:user) { login_user }
  let!(:video_resource) { create(:resource, file_type: 'video/mp4') }
  let!(:document_resource) { create(:resource, file_type: 'application/pdf') }
  let!(:unpublished_resource) { create(:resource, is_public: false) }

  it 'returns json data' do
    get documents_resources_path, format: :json

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
