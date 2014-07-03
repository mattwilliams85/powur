require 'spec_helper'

describe '/a/ranks' do

  before :each do
    login_user
  end

  describe '#index' do

    def find_delete_action(rank_id)
      rank = json_body['entities'].find { |rank| rank['properties']['id'] == rank_id }
      rank['actions'] && rank['actions'].find { |action| action['name'] == 'delete' }
    end

    it 'returns the list of ranks' do
      ranks = create_list(:rank, 2)
      get ranks_path, format: :json

      expect_classes 'ranks'
      expect_entities_count(2)

      action = find_delete_action(1)
      expect(action).to be_nil

      action = find_delete_action(2)
      expect(action).to_not be_nil
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
      ranks = create_list(:rank, 2)

      delete rank_path(2), format: :json

      expect_entities_count(1)
    end

  end

end