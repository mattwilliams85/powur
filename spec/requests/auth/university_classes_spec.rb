require 'spec_helper'

describe '/u/university_classes', type: :request do
  context 'signed in' do
    let(:product_enrollment) { double('enrollment') }
    let(:current_user) { login_user }
    let!(:certifiable_product1) { create(:certifiable_product) }
    let!(:product) { create(:product) }
    let!(:certifiable_product2) { create(:certifiable_product) }

    before do
      allow(current_user).to receive_message_chain(:product_enrollments, :find_by).and_return([product_enrollment])
    end

    it 'should return a list of certifiable products' do
      get university_classes_path, format: :json

      expect_entities_count(2)
      expect_classes 'university_classes'
    end
  end
end

describe '/u/university_classes/:id', type: :request do
  context 'signed in' do
    let(:product_enrollment) { double('enrollment') }
    let(:current_user) { login_user }
    let!(:certifiable_product) { create(:certifiable_product, bonus_volume: 123) }

    before do
      allow(current_user).to receive_message_chain(:product_enrollments, :find_by).and_return([product_enrollment])
    end

    it 'should return a json with a properties' do
      get university_class_path(certifiable_product), format: :json

      expect_classes 'university_class'
      expect_props(
        id: certifiable_product.id,
        name: certifiable_product.name,
        description: certifiable_product.description,
        image_url: certifiable_product.image_original_path,
        price: certifiable_product.bonus_volume,
        purchased: false
      )
    end

    context 'class was purchased by current user' do
      before do
        allow_any_instance_of(Product).to receive(:purchased_by?).with(current_user.id).and_return(true)
      end

      it 'marks it as purchased' do
        get university_class_path(certifiable_product), format: :json

        expect_classes 'university_class'
        expect_props(
          id: certifiable_product.id,
          purchased: true
        )
      end
    end
  end
end

describe 'POST /u/university_classes/:id/purchase', type: :request do
  context 'signed in' do
    let!(:current_user) { login_user }
    let!(:certifiable_product) { create(:certifiable_product, bonus_volume: 111) }

    it 'returns incomplete form error messages' do
      post(purchase_university_class_path(certifiable_product), {
        card:   { firstname: 'Bob' },
        format: :json
      })
      expect_input_errors(:number, :cvv)
    end

    it 'increases the user\'s available invites by 5' do
      allow_any_instance_of(Auth::UniversityClassesController).to receive(:process_purchase).and_return(true)
      allow_any_instance_of(Auth::UniversityClassesController).to receive(:send_purchased_notifications).and_return(true)

      expect(current_user.available_invites).to eq(0)

      post(purchase_university_class_path(certifiable_product), {
        card: {},
        format: :json
      })

      expect(current_user.available_invites).to eq(5)
    end

  end
end

describe 'POST /u/university_classes/:id/enroll', type: :request do
  context 'signed in' do
    let!(:current_user) { login_user }
    let!(:certifiable_product) { create(:certifiable_product, bonus_volume: 0) }
    let(:smarteru) { double(:smarteru, enrollment: nil, signin: '/redirectpath', ensure_account: true) }

    context 'with no enrollment restrictions' do
      before do
        allow(smarteru).to receive(:enroll).with(certifiable_product).and_return(true)
        allow(current_user).to receive(:smarteru).and_return(smarteru)
      end

      it 'enrolls user' do
        post enroll_university_class_path(certifiable_product), format: :json

        expect(response.code).to eql('200')
        expect(JSON.parse(response.body)['redirect_to']).to eql('/redirectpath')
      end
    end

    context 'class was already completed by current user' do
      before do
        product_enrollment.complete!
        allow(current_user).to receive(:smarteru).and_return(smarteru)
      end

      let(:product_enrollment) { create(:product_enrollment, user_id: current_user.id, product_id: certifiable_product.id) }

      it 'returns class completion alert' do
        post enroll_university_class_path(certifiable_product), format: :json
        expect(response.code).to eql('200')
        expect_alert_error
      end
    end

    context 'class is NOT free and was NOT purchased by current user' do
      before do
        allow_any_instance_of(Product).to receive(:bonus_volume).and_return(1)
      end

      it 'returns unauthorized' do
        post enroll_university_class_path(certifiable_product), format: :json
        expect(response.code).to eql('404')
        expect_alert_error
      end
    end
  end
end

describe 'POST /u/university_classes/:id/smarteru_signin', type: :request do
  context 'signed in' do
    let(:current_user) { login_user }
    let(:product) { create(:certifiable_product, bonus_volume: 0) }
    let(:smarteru) { double(:smarteru, signin: '/redirectpath', ensure_account: true) }
    let!(:product_enrollment) do
      create(:product_enrollment, user_id: current_user.id, product_id: product.id)
    end

    before do
      product_enrollment.update_column(:state, 'completed')
      allow(current_user).to receive(:smarteru).and_return(smarteru)
    end

    it 'returns a redirect path' do
      post smarteru_signin_university_class_path(product), format: :json

      expect(response.code).to eql('200')
      expect(JSON.parse(response.body)['redirect_to']).to eql('/redirectpath')
    end
  end
end

describe 'POST /u/university_classes/:id/check_enrollment', type: :request do
  let!(:current_user) { login_user }
  let(:product) { create(:certifiable_product, name: 'someproduct') }
  let(:smarteru) { double(:smarteru, enrollment: smarteru_learner_report) }
  let!(:product_enrollment) do
    create(:product_enrollment, user_id: current_user.id, product_id: product.id)
  end
  let(:smarteru_learner_report) {}

  before do
    allow(current_user).to receive(:smarteru).and_return(smarteru)
  end

  context 'enrollment started' do
    let(:smarteru_learner_report) do
      {
        course_name:    'someproduct',
        started_date: '2015-02-09 17:37:20.41'
      }
    end

    it 'should update enrollment state' do
      get check_enrollment_university_class_path(product), format: :json

      expect_props(id: product.id, state: 'started')
      expect(product_enrollment.reload.state).to eq('started')
    end
  end

  context 'enrollment completed' do
    let(:smarteru_learner_report) do
      {
        course_name:    'someproduct',
        completed_date: '2015-02-09 17:37:20.41'
      }
    end

    it 'should update enrollment state' do
      get check_enrollment_university_class_path(product), format: :json

      expect_props(id: product.id, state: 'completed')
      expect(product_enrollment.reload.state).to eq('completed')
    end
  end

  context 'enrollment not found' do
    it 'should update enrollment state' do
      get check_enrollment_university_class_path(create(:certifiable_product)), format: :json

      expect_alert_error
    end
  end
end
