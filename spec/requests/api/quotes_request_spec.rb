require 'spec_helper'

describe '/api/quotes', type: :request do
  before :each do
    login_api_user
  end

  describe 'GET /' do
    it 'returns the list of quotes for a user' do
      create_list(:quote, 3, user: @user)

      get api_quotes_path(format: :json), token_param

      expect_entities_count(3)

      quote = json_body['entities'].first
      id = quote['properties']['id']
      self_path = quote['links'].first['href']
      expect(self_path).to eq(api_quote_path(id: id))
    end
  end

  describe 'GET /:id' do
    it 'returns the quote detail' do
      quote = create(:quote, user: @user)

      get api_quote_path(id: quote, format: :json), token_param

      expect_classes 'quote'
    end
  end
end
