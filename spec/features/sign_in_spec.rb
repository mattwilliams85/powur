require 'spec_helper'
require_relative '../../app/models/user_activity'
require_relative '../../app/helpers/json_decorator'

describe "Sign In", :js do
  let!(:user) { create(:user) }

  before do
    visit "/"
    click_on 'Sign in'
  end

  context "when wrong data" do
    it "should show error message" do
      fill_in 'email', with: user.email
      fill_in 'password', with: 'wrongpassword'
      click_on 'Log in'
      expect(page).to have_content 'INVALID EMAIL OR PASSWORD'
      expect(current_path).to eq('/login')
    end
  end

  context "when correct data" do
    it "should sign in and redirect to a profile page" do
      fill_in 'email', with: user.email
      fill_in 'password', with: 'password'
      click_on 'Log in'
      sleep 2
      # expect(first('nav ul').text).to match /DASHBOARD/
      expect(page).to have_content 'DASHBOARD'
      expect(current_path).to eq('/u/dashboard')
    end
  end
end
