Action = Struct.new(:name, :title, :method, :href) do

  Field = Struct.new(:name, :type)

  def fields
    @fields ||= []
  end

  def field(name, type)
    fields << Field.new(name, type) and self
  end

end