require 'spec_helper'

describe Lead do
  describe '#save' do
    let(:lead) { create(:lead) }

    context 'when address is longer that 40 chars' do
      it 'should fail' do
        lead.address = 's' * 41
        expect(lead.save).to be false
      end
    end

    context 'when address is under 41 chars' do
      it 'should save' do
        lead.address = 's' * 40
        expect(lead.save).to be true
      end
    end
  end

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
