require 'spec_helper'

describe TypedStoreAccessor, type: :model do
  class FooMigration < ActiveRecord::Migration
    def change
      create_table :foos do |t|
        t.hstore :data, default: ''
      end unless ActiveRecord::Base.connection.table_exists? 'foos'
    end
  end

  class Foo < ActiveRecord::Base
    typed_store :data, string_field: :string,
                       int_field:    :integer,
                       date_field:   :date,
                       money_field:  :money
  end

  before :all do
    FooMigration.new.change
  end

  let(:foo) { Foo.new }
  let(:now) { DateTime.current }

  it 'saves and returns the correct types' do
    foo.data = {
      string_field: 'string_field',
      int_field:    42,
      date_field:   now,
      money_field:  315.23 }

    foo.save!

    result = Foo.find(foo.id)
    expect(result.string_field).to eq(foo.string_field)
    expect(result.int_field).to eq(foo.int_field)
    expect(result.date_field).to eq(foo.date_field)
    expect(result.money_field).to eq(foo.money_field)
  end
end
