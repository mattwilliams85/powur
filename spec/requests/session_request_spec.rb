require 'spec_helper'

describe 'login' do

  it 'describes the login input' do
    get '/login', format: :json
    # binding.pry
  end
end