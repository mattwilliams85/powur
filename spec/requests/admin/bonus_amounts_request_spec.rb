require 'spec_helper'

describe '/a/bonuses/:admin_bonus_id/bonus_amounts' do
  before do
    login_user
    create_list(:rank, 4)
    @path = create(:rank_path)
  end

  def amounts
    json_body['entities'].find { |e| e['class'].include?('bonus_levels') }
  end

  def create_action
    amounts['actions'].find { |a| a['name'] == 'create' }
  end

  describe 'POST /' do

    it 'adds a bonus level to to a bonus' do
      bonus = create(:seller_bonus)
      post bonus_amounts_path(bonus),
           rank_path_id: @path.id,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect_classes 'bonus'

      amounts = json_body['entities'].find do |e|
        e['class'].include?('bonus_amounts')
      end

      expect(amounts['entities'].size).to eq(1)

      level = amounts['entities'].first

      padded_value = level['properties']['amounts'].last
      expect(padded_value).to eq('0.0')
    end
  end
end
