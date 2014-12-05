require_relative '../spec_helper'
require 'rake'

describe 'admin seed' do
  before { Sunstand::Application.load_tasks }
  it "should seed admin users without exception" do
    User.delete_all
    expect{ Rake::Task["db:seed"].invoke }.to change{User.count}.by(7)
    expect { Rake::Task['db:seed'].invoke }.not_to raise_exception
  end
  
end

