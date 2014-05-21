module SpecHelpers

  def json_body
    response[:json_body] ||= MultiJson.load(response.body)
  end

  def expect_input_error(input)
    expect(json_body['error']['input']).to eq(input.to_s)
  end

end