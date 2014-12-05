require_relative '../spec_helper'
require 'rake'

describe 'bonus plan seed' do
  before { Sunstand::Application.load_tasks }
  it 'should create a new bonus plan' do
    expect { Rake::Task['sunstand:seed:bonus_plan'].invoke }
      .to change { BonusPlan.count }.by(1)
  end

  it { expect {
    Rake::Task['sunstand:seed:bonus_plan'].invoke
  }.not_to raise_exception }
end
