module TestResponse
  def json
    response[:json] ||= begin
      type = response.content_type
      type.must_match /json/, "Expected json response, got '#{type}'"
      MultiJson.load(response.body)
    end
  end

  def siren
    response[:siren] ||= SirenResponse.new(json)
  end

  class SirenResponse < Hashie::Mash
    def klass
      self['class']
    end

    def to_s
      klass.inspect
    end

    def klass?(value)
      klass.include?(value.to_s)
    end

    def action(name)
      actions && actions.find { |a| a['name'] == name.to_s }
    end

    def action?(name)
      !action(name).nil?
    end

    def entity(rel = nil)
      entities && entities.find do |e|
        if rel
          e['rel'].include?(rel.to_s)
        elsif block_given?
          yield(e)
        end
      end
    end

    def entity?(rel)
      !entity(rel).nil?
    end

    def must_be_class(name)
      klass?(name).must_equal true, "Expected #{self} to include '#{name}'"
    end

    def must_have_action(name)
      action?(name).must_equal true, "Expected action '#{name}' in #{self}"
    end

    def wont_have_action(name)
      action?(name).must_equal false, "#{self} should not have action '#{name}'"
    end

    def must_have_entity_size(size)
      entities.wont_be_nil && entities.size.must_equal(size)
    end

    def must_have_entity(rel)
      entity?(rel).must_equal true, "Expected entity '#{rel}' in #{self}"
    end

    def must_have_entities(*rels)
      rels.each { |rel| must_have_entity(rel) }
    end

    def props_must_equal(key_values)
      key_values.each do |key, value|
        self.properties[key]
          .must_equal(value, "Expected property #{key} to equal #{value}")
      end
    end

    def field(name)
      fields && fields.find { |f| f.name == name.to_s }
    end

    def field?(name)
      !field(name).nil?
    end

    def must_have_fields(*names)
      fields.wont_be_nil
      names.each do |name|
        field?(name).must_equal(true, "Expected field '#{name}'")
      end
    end

    def must_have_field(name)
      must_have_fields(name)
    end
  end
end