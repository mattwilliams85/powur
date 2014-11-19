module EyecueIpayout
  # Class representation of a Parameter object
  # allowing access to the Parameter name, as well
  # as other useful stuff like whether or not the API
  # requires it or the expected type.

  # It's worth lies in DEFINING the api constraints
  # through our wrapper.

  # Also, If the API changes,
  # we'll only have to change the wrapper in one place
  # (during the instantiation of this object)
  class ServiceParam
    attr_accessor :value, :name
    # Initializes new ServiceParam object
    #
    # @param [String] name
    # @param [Hash] expected_type
    # @param [Boolean] required
    # @return [EyecueIpayout::ServiceParam]
    # @instantiate EyecueIpayout::ServiceParam.new("FirstName", "String", true)

    def initialize(name, expected_type = 'String', required = false)
      @name = name
      @value = ''
      @expected_type = expected_type
      @required = required
    end

    def to_s
      @name
    end
  end
end
