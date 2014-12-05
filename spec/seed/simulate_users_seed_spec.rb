require_relative '../spec_helper'
require 'rake'

describe 'simulate user seed' do
  before { Sunstand::Application.load_tasks }
  it "should seed users without exception" do
    expect{ Rake::Task["sunstand:simulate:users"].invoke("[5,1,1]") }.to change{User.count}.by(5)
    expect { Rake::Task['sunstand:simulate:users'].invoke("[5,1,1]") }.not_to raise_exception 
  end
  
end

