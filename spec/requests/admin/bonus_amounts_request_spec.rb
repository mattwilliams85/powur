require 'spec_helper'

describe '/a/bonuses/:admin_bonus_id/bonus_amounts' do
  before do
    login_user
    create_list(:rank, 3)
    @path = create(:rank_path)
  end

  def amounts
    json_body['entities'].find { |e| e['class'].include?('bonus_levels') }
  end

  def create_action
    amounts['actions'].find { |a| a['name'] == 'create' }
  end

  describe 'POST /' do
    let(:bonus) { create(:seller_bonus) }

    it 'adds a bonus level to to a bonus' do
      post bonus_amounts_path(bonus, format: :json),
           amounts:      [ 240.00, 120.00, '75.00' ]

      expect_classes 'bonus'

      amounts = json_body['entities'].find do |e|
        e['class'].include?('bonus_amounts')
      end

      expect(amounts['entities'].size).to eq(1)
      level = amounts['entities'].first
      amounts = level['properties']['amounts']
      expect(amounts).to eq([ '240.0', '120.0', '75.0' ])
    end

    it 'does not allow posting amounts greater than what is available' do
      post bonus_amounts_path(bonus, format: :json),
           amounts:      [ '1010.00', 120.00, '75.00' ]

      expect_input_error('amounts')
    end
  end
end
