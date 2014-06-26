require 'spec_helper'

describe '/a/ranks' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns the list of ranks' do
      create_list(:rank, 4)
      get ranks_path

      expect_classes 'ranks'
      expect(json_body['entities'].size).to eq(4)
    end

  end

end