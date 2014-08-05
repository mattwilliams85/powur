require 'spec_helper'

describe '/a/quotes' do

  before :each do
    login_user
  end

  describe '/' do

    it 'renders a list of quotes' do
      create_list(:quote, 5)

      get admin_quotes_path, format: :json, limit: 3

      expect_classes 'quotes'
      expect_entities_count(3)

      get admin_quotes_path, format: :json, p: 2, limit: 3
      expect_entities_count(2)
    end
  end

end
