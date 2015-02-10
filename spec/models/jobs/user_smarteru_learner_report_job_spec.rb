require 'spec_helper'

describe Jobs::UserSmarteruLearnerReportJob, type: :model do
  before do
    allow_any_instance_of(ProductEnrollment).to receive(:start_learner_report_polling).and_return(true)
    expect_any_instance_of(User).to receive(:smarteru_learner_reports).once.and_return(smarteru_learner_reports)
  end

  let(:user) { create(:user) }
  let(:product) { create(:certifiable_product, name: 'Shine') }
  let!(:product_enrollment) { ProductEnrollment.create(user_id: user.id, product_id: product.id) }

  let(:job) { Jobs::UserSmarteruLearnerReportJob.new(user.id) }

  context 'smarterU enrollment doesn\'t exist' do
    let(:smarteru_learner_reports) { [] }

    it 'should mark enrollment as removed' do
      job.perform
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('removed')
    end
  end

  context 'smarterU class started' do
    let(:smarteru_learner_reports) do
      [{
        course_name: 'Shine',
        started_date: "2015-02-09 17:37:20.41"
      }]
    end

    it 'should mark enrollment as started' do
      job.perform
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('started')
    end
  end

  context 'smarterU class completed' do
    let(:smarteru_learner_reports) do
      [{
        course_name: 'Shine',
        completed_date: "2015-02-09 17:37:20.41"
      }]
    end

    it 'should mark enrollment as completed' do
      job.perform
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('completed')
    end
  end

  context 'smarterU class enrollment with no changes' do
    let(:smarteru_learner_reports) do
      [{
        course_name: 'Shine'
      }]
    end

    it 'should enqueue another job' do
      expect_any_instance_of(ProductEnrollment).to receive(:start_learner_report_polling).once.and_return(true)
      job.perform
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('enrolled')
    end
  end

  context 'smarterU api call error' do
    let(:smarteru_learner_reports) { nil }

    it 'should enqueue another job' do
      expect_any_instance_of(ProductEnrollment).to receive(:start_learner_report_polling).once.and_return(true)
      expect { job.perform }.to raise_error
    end
  end
end
