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
      create_list(:rank, 4)
      get ranks_path

      expect_classes 'ranks'
      expect_entities_count(4)

      action = find_delete_action(3)
      expect(action).to be_nil

      action = find_delete_action(4)
      expect(action).to_not be_nil
    end

  end

  describe '#create' do

    it 'creates a new rank' do
      post ranks_path, title: 'Jedi'

      expect_classes 'rank'
      expect(json_body['properties']['title']).to eq('Jedi')
    end

  end

  describe '#destroy' do

    it 'only allows the last rank to be deleted' do
      ranks = create_list(:rank, 2)

      delete rank_path(ranks.first)

      expect_alert_error
    end

    it 'deletes the last rank' do
      ranks = create_list(:rank, 2)

      delete rank_path(2)

      expect_entities_count(1)
    end

  end

end