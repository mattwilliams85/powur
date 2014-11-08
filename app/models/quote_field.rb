class QuoteField < ActiveRecord::Base
  belongs_to :product
  has_many :lookups, class_name:  'QuoteFieldLookup',
                     foreign_key: :quote_field_id,
                     dependent:   :destroy

  enum data_type: { text: 1, number: 2, date: 3, lookup: 4, boolean: 5 }

  validates_presence_of :product_id, :name, :data_type

  def add_or_update_lookup(attrs)
    if attrs[:value].blank?
      delete_lookup_by_identifier(attrs[:identifier])
    else
      create_or_update_lookup(attrs)
    end
  end

  def lookups_from_records(records)
    records.each { |row| lookup_from_row(row) }
  end

  def lookups_from_csv(csv)
    CSV.parse(csv) { |row| lookup_from_row(row) }
  end

  def view_type
    if lookup?
      :select
    elsif boolean?
      :checkbox
    else
      data_type
    end
  end

  def normalize(value)
    if boolean?
      ![ 0, false, 'false', nil ].include?(value)
    elsif number? && !value.nil?
      value.to_i
    else
      value
    end
  end

  private

  def lookup_from_row(row)
    attrs = { value: row[0].presence.to_s,
              identifier: row[1].present? ? row[1].to_s : row[0].to_s }
    attrs[:group] = row[2].presence.to_s if row[2].present?
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
