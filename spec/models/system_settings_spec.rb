require 'spec_helper'

describe SystemSettings, type: :model do

  it 'sets a default value' do
    SystemSettings.defaults[:foo] = 'bar'

    expect(SystemSettings.foo).to eq('bar')
  end

  it 'does not set a default value if a value is already in the db' do
    SystemSettings.color = 'blue'

    SystemSettings.defaults[:color] = 'gold'
    
    expect(SystemSettings.color).to eq('blue')
  end

  it 'sets a default value saved in the db' do
    SystemSettings.save_default(:team, 'cubs')

    expect(SystemSettings.team).to eq('cubs')
  end

  it 'does not save a default if it exists' do
    SystemSettings.drink = 'ice tea'

    SystemSettings.save_default(:drink, 'milk')

    expect(SystemSettings.drink).to eq('ice tea')
  end
end