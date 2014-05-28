module SpecHelpers

  def login_user
    @user = create(:user)
    session[:user_id] = @user.id
  end

  def json_body
    response[:json_body] ||= MultiJson.load(response.body)
  end

  def expect_200
    expect(response.status).to eq(200)
  end

  def expect_input_error(input)
    expect(json_body['error']['input']).to eq(input.to_s)
  end

  def expect_alert_error
    expect(json_body['error']['type']).to eq('alert')
  end

end