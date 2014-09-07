require 'spec_helper'

describe '/quote' do

  before :each do
    @user = create(:user, url_slug: 'dude')
  end

  let(:params) {{
    email:       'someone@somewhere.com',
    first_name:  'some',
    last_name:   'dude',
    phone:       '8585551212',
    sponsor:      @user.url_slug,
    product_id:   1,
    format:       :json }}

  it 'renders a new quote entity' do
    get sponsor_quote_path(@user.url_slug), format: :json

    expect_200
    expect_classes 'quote'
    expect_actions 'create'
  end

  it 'redirects when a promoter does not exist' do
    get sponsor_quote_path('foo'), format: :json

    expect(json_body.keys).to include('redirect')
  end

  it 'creates a new promoter quote' do
    post quote_path, params

    expect_200

    expect_classes 'quote'
    expect_actions 'update'
  end

end
