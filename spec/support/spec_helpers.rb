# helper methods for spec tests
module SpecHelpers
  def login_user
    @user = create(:user)
    if defined?(session)
      session[:user_id] = @user.id
    else
      post login_path, email: @user.email, password: 'password'
    end
  end

  def login_api_user
    @token = create(:api_token)
    @user = @token.user
  end

  def json_body
    response[:json_body] ||= MultiJson.load(response.body)
  end

  def response_to_file(name)
    File.open(File.join('/tmp', name), 'w') { |f| f.write(response.body) }
  end

  def expect_200
    expect(response.status).to eq(200)
  end

  def expect_input_error(input)
    expect(json_body['error']).to_not(
      be_nil,
      "expected error json, got json keys: [#{json_body.keys.join(',')}]")

    expect(json_body['error']['input']).to eq(input.to_s)
  end

  def expect_alert_error
    expect(json_body['error']['type']).to eq('alert')
  end

  def expect_classes(*args)
    expect(json_body['class']).to include(*args)
  end

  def expect_props(args = {})
    args.each do |key, value|
      expect(json_body['properties'][key.to_s]).to eq(value)
    end
  end

  def expect_entities(*args)
    entities = json_body['entities'].map { |a| a['rel'] }.flatten
    expect(entities).to include(*args)
  end

  def expect_entities_count(count)
    expect(json_body['entities'].size).to eq(count)
  end

  def expect_actions(*args)
    expect(json_body['actions'].map { |a| a['name'] }).to include(*args)
  end

  def expect_confirm
    expect(json_body['properties']['_message']).to_not be_nil
    expect(json_body['properties']['_message']['confirm']).to_not be_nil
  end

  def expect_api_error(error = :invalid_request)
    expect(json_body['error']).to eq(error.to_s)
  end

  def authorize_header(u, p = nil)
    u, p = u.id, u.secret if p.nil?
    basic = ActionController::HttpAuthentication::Basic
    header = basic.encode_credentials(u, p)
    { 'HTTP_AUTHORIZATION' => header }
  end

  def bearer_header(token_value)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token_value}" }
  end

  def api_header
    login_api_user
    bearer_header(@token.access_token)
  end

  def api_param
    login_api_user
    { access_token: @token.access_token }
  end
end
