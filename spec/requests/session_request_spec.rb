require 'spec_helper'

describe 'login' do

  it 'describes the login input' do
    get '/login', format: :json
    
    expect_200

    expect(json_body['class']).to include('session')
  end
end