require 'spec_helper'

describe QuoteField, type: :model do

  before :each do
    @field = create(:quote_field, data_type: :lookup)
  end

  describe '#lookups_from_records' do

    it 'updates existing fields with the same identifier' do
      lookups = create_list(:quote_field_lookup, 2, quote_field: @field)
      records = [ [ 'foo', lookups.first.identifier ],
                  [ 'bar', lookups.last.identifier ] ]
      @field.lookups_from_records(records)

      expect(@field.lookups.size).to eq(2)
      lookup = @field.lookups.first
      expect(lookup.value).to eq('foo')
      expect(lookup.identifier).to eq(lookups.first.identifier)
      lookup = @field.lookups.last
      expect(lookup.value).to eq('bar')
      expect(lookup.identifier).to eq(lookups.last.identifier)
    end

  end

  describe '#lookups_from_csv' do

    it 'creates field lookups from a csv without an identifier' do
      csv = CSV.generate do |s|
        s << [ 'foo', '' ]
        s << [ 'bar', '' ]
      end
      @field.lookups_from_csv(csv)

      expect(@field.lookups.size).to eq(2)
      lookup = @field.lookups.first
      expect(lookup.value).to eq('foo')
      expect(lookup.identifier).to eq(1)
      lookup = @field.lookups.last
      expect(lookup.value).to eq('bar')
      expect(lookup.identifier).to eq(2)
    end

    it 'deletes existing fields with empty values' do
      lookups = create_list(:quote_field_lookup, 2, quote_field: @field)
      csv = CSV.generate do |s|
        s << [ '', lookups.first.identifier ]
        s << [ '', lookups.last.identifier ]
      end
      @field.lookups_from_csv(csv)

      expect(@field.lookups.size).to eq(0)
    end
  end

end
