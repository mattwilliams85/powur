require 'spec_helper'

describe '/a/rank_paths', type: :request do

  before :each do
    login_user
  end

  describe '/' do
    it 'returns the list of rank paths' do
      create_list(:rank_path, 3)

      get rank_paths_path, format: :json

      expect_entities_count(3)
    end

    it 'creates a new rank_path' do
      post rank_paths_path, name: 'foo', description: 'bar', format: :json

      expect_entities_count(1)
      path_props = json_body['entities'].first['properties']
      expect(path_props['name']).to eq('foo')
      expect(path_props['description']).to eq('bar')
    end
  end

  describe '/:id' do
    it 'updates a rank path' do
      rank_path = create(:rank_path)

      patch rank_path_path(rank_path), name: 'foo', format: :json

      expect_entities_count(1)
      result = json_body['entities'].first
      expect(result['properties']['name']).to eq('foo')
    end

    it 'deletes a rank path' do
      rank_path = create(:rank_path)

      delete rank_path_path(rank_path), format: :json
      expect_entities_count(0)
    end

  end
end
