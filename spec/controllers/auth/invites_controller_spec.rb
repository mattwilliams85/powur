require 'spec_helper'

describe Auth::InvitesController do
  render_views

  before :each do
    @user = login_user(auth: true)
  end

  describe '#index' do
    it 'renders a list of invites' do
      create_list(:invite, 3, sponsor: @user)

      get :index

      expect_200

      expect_classes('invites', 'list')
      expect(json_body['entities'].size).to eq(3)
    end
  end

  describe '#create' do
    let(:invite_params) do
      { email:      'paul.walker+invite@eyecuelab.com',
        first_name: 'paul',
        last_name:  'walker',
        phone:      '858.555.1212' }
    end

    context 'when current user is NOT a partner' do
      it 'does not allow to create an invite' do
        post :create, invite_params

        expect_alert_error
      end
    end

    context 'when current user is a partner' do
      before do
        allow_any_instance_of(User).to receive(:partner?).and_return(true)
      end

      it 'creates an invite' do
        allow_any_instance_of(Invite)
          .to receive(:delay).and_return(double(send_sms: true))
        post :create, invite_params

        expect_200

        expect_classes('invite')
        expect(json_body['properties']['email']).to eq(invite_params[:email])
      end

      [ :first_name, :last_name ].each do |input|
        it "requires #{input}" do
          post :create, invite_params.reject { |k, _v| k == input }

          expect_input_error(input)
        end
      end

      it 'does not allow you to invite yourself' do
        post :create, invite_params.merge(email: @user.email)
        expect_input_error(:email)
      end

      it 'does not allow creating an invite with an existing email' do
        user = create(:user)
        post :create, invite_params.merge(email: user.email)

        expect_input_error(:email)
      end
    end
  end

  describe '#delete' do
    it 'deletes an invite' do
      invite = create(:invite, sponsor: @user)

      delete :delete, id: invite.id

      expect_200
      expect(Invite.find_by_id(invite.id)).to be_nil
    end
  end
end
