require_relative '../spec_helper'
require 'rake'

describe 'admin seed' do
  before { Sunstand::Application.load_tasks }
  it "should create more users" do
    expect{ Rake::Task["db:seed"].invoke }.to change{User.count}.by(7)
  end
  
  it { expect { Rake::Task['db:seed'].invoke }.not_to raise_exception }
end