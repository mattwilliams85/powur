require 'spec_helper'

describe ProductEnrollment do
  let(:user) { double(:user) }
  let(:product) { double(:product) }

  describe '#complete!' do
    let(:enrollment) { create(:product_enrollment) }

    before do
      allow_any_instance_of(ProductEnrollment).to receive(:start_learner_report_polling).and_return(true)
      allow(enrollment).to receive(:product).and_return(product)
      allow(enrollment).to receive(:user).and_return(user)
    end

    context 'non-required class' do
      it 'should NOT try to create ipayout account' do
        allow(product).to receive(:is_required_class).and_return(false)
        expect(enrollment).to_not receive(:find_or_create_ipayout_account).with(user)
        enrollment.complete!
      end
    end
  end
end
