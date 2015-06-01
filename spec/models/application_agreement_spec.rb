require 'spec_helper'

describe ApplicationAgreement, type: :model do

  describe '#current' do
    let(:scope) { double(sorted: double(first: 'banana')) }
    before do
      allow(ApplicationAgreement).to receive(:where).with('published_at is not null').and_return(scope)
    end

    it 'returns latest published agreement' do
      expect(ApplicationAgreement.current).to eq('banana')
    end
  end
end
