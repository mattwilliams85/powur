require 'spec_helper'
# require_relative '../../app/models/user_activity'
# require_relative '../../app/helpers/json_decorator'

describe 'Sign In', :js, type: :feature do
  let!(:user) { create(:user) }

  before do
    visit '/'
    click_on 'Sign In'
  end

  context 'when wrong data' do
    it 'should show error message' do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'wrongpassword'
      click_on 'Sign In'
      expect(page).to have_content 'Oops, wrong email or password'
    end
  end

  context 'when correct data' do
    it 'should sign in and redirect to a profile page' do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      VCR.use_cassette('sign_in_and_redirect') do
        click_on 'Sign In'
        sleep 2
        # expect(first('nav ul').text).to match /DASHBOARD/
        expect(page).to have_content 'DASHBOARD'
        expect(current_path).to eq('/u/dashboard')
      end
    end
  end
end
