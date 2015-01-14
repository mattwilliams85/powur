require 'spec_helper'

describe 'Edit Password', :js, type: :feature do
  let!(:user) do
    create(:user, reset_token: token, reset_sent_at: DateTime.current)
  end
  let(:token) { SecureRandom.urlsafe_base64(15) }

  before do
    visit '/#/edit-password/' + token
  end

  context 'when wrong data' do
    it 'should show error message' do
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirm', with: 'wrongconfirmation'
      click_on 'Update Password'
      expect(page).to have_content 'The confirm password does not match'
    end
  end

  context 'when correct data' do
    it 'should sign in and redirect to a profile page' do
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirm', with: 'password'
      click_on 'Update Password'
      expect(page).to have_content 'Password reset successfully'
    end
  end
end
