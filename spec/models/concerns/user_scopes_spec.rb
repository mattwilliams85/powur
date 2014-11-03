require 'spec_helper'

describe UserScopes, type: :model do

  describe '::with_downline_counts' do

    it 'returns the child counts' do
      parent = create(:user)
      user1 = create(:user, sponsor: parent)
      user2 = create(:user, sponsor: parent)
      user3 = create(:user, sponsor: parent)
      create_list(:user, 1, sponsor: user1)
      create_list(:user, 2, sponsor: user2)
      create_list(:user, 3, sponsor: user3)

      results = User.with_downline_counts.with_parent(parent.id)
      { user1.id => 1, user2.id => 2, user3.id => 3 }.each do |id, count|
        result = results.find { |r| r.id == id }
        expect(result).to be
        expect(result.attributes['downline_count']).to eq(count)
      end
    end
  end

end
