require 'spec_helper'
require 'rake'

describe "powur:smarteru_reports" do
  before do
    allow_any_instance_of(User).to receive(:smarteru).and_return(smarteru)
    Rake::Task.define_task(:environment)
    Rake.application.rake_require "tasks/smarteru"
  end

  after do
    Rake::Task["powur:smarteru_reports"].reenable
  end

  let(:smarteru) { double(:smarteru, enrollment: smarteru_learner_report) }
  let(:user) { create(:user) }
  let(:product) { create(:certifiable_product, name: 'Shine') }
  let!(:product_enrollment) { ProductEnrollment.create(user_id: user.id, product_id: product.id) }

  context 'smarterU enrollment doesn\'t exist' do
    let(:smarteru_learner_report) { nil }

    it 'does not update enrollment' do
      Rake::Task["powur:smarteru_reports"].invoke
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('enrolled')
    end
  end

  context 'smarterU class started' do
    let(:smarteru_learner_report) do
      {
        course_name: 'Shine',
        started_date: "2015-02-09 17:37:20.41"
      }
    end

    it 'should mark enrollment as started' do
      Rake::Task["powur:smarteru_reports"].invoke
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('started')
    end
  end

  context 'smarterU class completed' do
    let(:smarteru_learner_report) do
      {
        course_name: 'Shine',
        completed_date: "2015-02-09 17:37:20.41"
      }
    end

    it 'should mark enrollment as completed' do
      Rake::Task["powur:smarteru_reports"].invoke
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('completed')
    end
  end

  context 'smarterU class enrollment with no changes' do
    let(:smarteru_learner_report) do
      {
        course_name: 'Shine'
      }
    end

    it 'does not update enrollment' do
      Rake::Task["powur:smarteru_reports"].invoke
      expect(ProductEnrollment.find(product_enrollment.id).state).to eq('enrolled')
    end
  end
end
