class QuoteField < ActiveRecord::Base
  belongs_to :product
  has_many :lookups, class_name:  'QuoteFieldLookup',
                     foreign_key: :quote_field_id,
                     dependent:   :destroy

  enum data_type: { string: 1, number: 2, date: 3, lookup: 4 }

  validates_presence_of :product_id, :name, :data_type, :required

  def add_or_update_lookup(attrs)
    if attrs[:value].blank?
      delete_lookup_by_identifier(attrs[:identifier])
    else
      create_or_update_lookup(attrs)
    end
  end

  def lookups_from_records(records)
    counter = 0
    records.each do |row|
      lookup_from_row(row, counter += 1)
    end
  end

  def lookups_from_csv(csv)
    counter = 0
    CSV.parse(csv) do |row|
      lookup_from_row(row, counter += 1)
    end
  end

  private

  def lookup_from_row(row, counter)
    attrs = { value: row[0].presence }
    attrs[:identifier] = row[1].presence ? row[1].to_i : counter
    add_or_update_lookup(attrs)
  end

  def delete_lookup_by_identifier(identifier)
    lookups.where(identifier: identifier).delete_all
  end

  def create_or_update_lookup(attrs)
    existing = lookups.where(identifier: attrs[:identifier]).first
    if existing
      QuoteFieldLookup.update(existing.id, value: attrs[:value])
    else
      lookups.create!(attrs)
    end
  end
end
