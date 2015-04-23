require 'spec_helper'

describe '/a/ranks' do

  before do
    login_user
  end

  describe 'GET /' do

    def find_rank(index)
      json_body['entities'][index]
    end

    def find_action(index, name)
      rank = find_rank(index)
      rank['actions'] && rank['actions'].find { |a| a['name'] == name }
    end

    it 'returns the list of ranks' do
      qualified_rank = create(:qualified_rank)
      create_list(:rank, 2)
      get ranks_path, format: :json

      expect_classes 'ranks'
      expect_entities_count(3)

      action = find_action(0, 'delete')
      expect(action).to be_nil

      action = find_action(2, 'delete')
      expect(action).to_not be_nil

      rank = json_body['entities'].find do |e|
        e['properties']['id'] == qualified_rank.id
      end
      qual_list = rank['entities'].find do |e|
        e['rel'] && e['rel'].include?('rank-qualifications')
      end
      expect(qual_list).to be
    end

    def qual_list(rank_id)
      rank = find_rank(rank_id)
      rank['entities'].find { |e| e['class'].include?('qualifications') }
    end

    def qual_list_action(rank_id, name)
      quals = qual_list(rank_id)
      quals['actions'] &&
        quals['actions'].find { |a| a['name'] == name }
    end

    def create_action_result
      create_list(:rank, 2)
      get ranks_path, format: :json
      qual_list_action(1, 'create')
    end

    it 'does not render create quals without a rank_path' do
      create(:product)
      expect(create_action_result).to_not be
    end

    it 'does not render create quals without a product' do
      Product.destroy_all
      create(:rank_path)
      expect(create_action_result).to_not be
    end

    it 'renders create quals when there are product and ranks_path' do
      create(:product)
      create(:rank_path)
      expect(create_action_result).to be
    end

  end

  describe '#create' do

    it 'creates a new rank' do
      post ranks_path, title: 'Jedi', format: :json

      expect_classes 'rank'
      expect(json_body['properties']['title']).to eq('Jedi')
    end

  end

  describe '#update' do

    it 'updates a rank' do
      rank = create(:rank)

      patch rank_path(rank), title: 'Padwan', format: :json

      expect(json_body['properties']['title']).to eq('Padwan')
    end

  end

  describe '#destroy' do

    it 'only allows the last rank to be deleted' do
      ranks = create_list(:rank, 2)

      delete rank_path(ranks.first), format: :json

      expect_alert_error
    end

    it 'deletes the last rank' do
      create_list(:qualified_rank, 2)

      delete rank_path(Rank.last), format: :json
      expect_entities_count(Rank.count)
    end

  end
end
