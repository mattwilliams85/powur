require 'spec_helper'

describe Lead do
  describe '#destroy' do
    before do
      allow(Lead).to receive(:eligible_zip?).and_return(true)
      lead.destroy
    end

    context 'while NOT submitted' do
      let(:lead) { create(:lead) }

      it 'should delete the record' do
        expect { lead.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'while submitted' do
      let(:lead) { create(:submitted_lead) }

      it 'should not delete the record' do
        expect(lead.reload).to be_a Lead
      end
    end
  end
end
