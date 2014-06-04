require 'spec_helper'

describe '/customers' do

  describe '#index' do

    before :each do
      login_user
    end

    it 'returns the list of customers for a promoter' do
      create_list(:customer, 7, promoter: @user)

      get customers_path, format: :json
      expect_classes('list', 'customers')
      expect_actions('create')
    end
  end

end