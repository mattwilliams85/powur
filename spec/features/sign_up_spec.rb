require 'spec_helper'

describe 'Sign Up', :js, type: :feature do
  before do
    visit '/#/sign-up'
  end

  context 'when wrong invite code' do
    it 'should show error message' do
      expect(page).not_to have_content("Invalid invite code")
      fill_in 'invite_code', with: 'wrongcode'
      click_on 'validate_invite_submit'
      expect(page).to have_content("Invalid invite code")
    end
  end

  context 'when correct data' do
    let(:invite) { create(:invite) }

    it 'should sign in and redirect to a profile page' do
      expect(page).to have_button("Register for free", disabled: true)
      fill_in 'invite_code', with: invite.id
      click_on 'validate_invite_submit'
      click_on 'Register for free'
      expect(page).to have_content("Phone is required")
      expect(page).to have_content("Password is required")
      expect(page).to have_content("Password confirmation is required")
      expect(page).to have_content("Zip is required")
      expect(page).to have_content("You didn't agree to the terms and privacy policy")

      fill_in 'user_phone', with: '1231231234'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      fill_in 'user_zip', with: '12345'
      check('I agree to the Terms of Service and Privacy Policy')

      VCR.use_cassette('ipayout_register') do
        click_on 'Register for free'
        # Button should be disabled while request is processing
        expect(page).to have_button("Register for free", disabled: true)
        sleep 4
        expect(page).to have_content 'successfully Signed Up'
      end
    end
  end
end
