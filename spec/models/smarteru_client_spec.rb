require 'spec_helper'

describe SmarteruClient, type: :model do
  let(:user) { create(:user, smarteru_employee_id: '123') }
  let(:client) { described_class.new(user) }

  it 'initializes with user' do
    initialized_client = described_class.new(user)
    expect(initialized_client.user).to eq(user)
  end

  describe '#employee_id' do
    subject { client.employee_id }

    it { is_expected.to eq(user.smarteru_employee_id) }
  end

  describe '#account' do
    subject { client.account }
    before do
      expect(client.client.users).to receive(:get).once.with(user.smarteru_employee_id).and_return('banana')
    end

    it { is_expected.to eq('banana') }

    it 'should store data in the instance variable to prevent multiple api calls' do
      client.account
      client.account
    end
  end

  describe '#create_account' do
    subject { client.create_account(password: 'smarterupassword') }
    let(:api_response) { double(:api_response, result: {employee_id: 'employee_id_from_api'}) }
    let(:account_options) do
      {
        email:        user.email,
        employee_i_d: "powur:#{user.id}",
        given_name:   user.first_name,
        surname:      user.last_name,
        password:     'smarterupassword',
        group:        client.group
      }
    end
    before do
      expect(client.client.users).to receive(:create).once.with(account_options).and_return(api_response)
      expect(client).to receive(:update_employee_id).once.with(api_response.result[:employee_id]).and_return(true)
    end

    it { is_expected.to eq(true) }
  end

  describe '#signin' do
    subject { client.signin }
    let(:api_response) { double(:api_response, result: {redirect_path: 'example.com'}) }
    before do
      expect(client.client.users).to receive(:signin).once.and_return(api_response)
    end

    it { is_expected.to eq('example.com') }
  end

  describe '#enroll' do
    let(:product) { create(:certifiable_product, smarteru_module_id: 'a1') }

    context 'not yet enrolled in the class' do
      before do
        expect(client).to receive(:enrollment).once.with(product).and_return(nil)
      end

      it 'should enroll through the api' do
        expect(client.client.users).to receive(:enroll).once.with(user.smarteru_employee_id, client.group, product.smarteru_module_id).and_return(true)
        enrollment = client.enroll(product)
        expect(enrollment).to be_a(ProductEnrollment)
        expect(enrollment.product_id).to eq(product.id)
        expect(enrollment.user_id).to eq(user.id)
      end
    end

    context 'already enrolled in the class' do
      before do
        expect(client).to receive(:enrollment).once.with(product).and_return('existing_enrollment')
      end

      it 'should NOT reenroll through the api' do
        expect(client.client.users).not_to receive(:enroll)
        expect(client.enroll(product)).to eql('existing_enrollment')
      end
    end
  end

  pending '#normalize_employee_id!'
end
