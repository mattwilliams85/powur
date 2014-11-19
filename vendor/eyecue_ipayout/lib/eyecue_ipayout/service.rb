require 'eyecue_ipayout/service_param'

module EyecueIpayout
  # Custom error class for rescuing from all eWallet errors
  class Service
    attr_accessor :name, :response_parameters, :parameters

    # Initializes new ServiceParam object
    #
    # @param [String] name
    # @param [Array] request_param_names
    # @param [Array] response_param_names
    # @return [EyecueIpayout::Service]
    # @instantiate EyecueIpayout::Service.new("eWallet_GetCustomerDetails")

    def initialize(name)
      @name = name
      @request_param_names = []
      @response_param_names = []

      # Hash of this service's parameters
      # wherein the key is the parameter name
      # and the value is the actual EyecueIpayout::ServiceParam object
      # parameters['eWallet_GetCustomerDetails'] =
      #             <Object EyecueIpayout::ServiceParam>
      @parameters = {}

      # This is a list of keys to use when referencing the API response
      @response_parameters = []
    end

    def to_s
      @name
    end

    # return an array of param names
    # expected for this service call
    def request_param_list
      @parameters.keys
    end

    # our native parameters hash holds service_param
    # objects.  This returns the param_name => param_value hash
    def param_hash
      param_hash = {}
      @parameters.each do |param_name, param_obj|
        param_hash[param_name] = param_obj.value
      end
      param_hash

    end

    # This is a shortcut method for adding parameters
    # without having to instantiate the ServiceParam
    # outside of this class.
    def add_param(param_name, expected_type, required)
      unless @parameters.key? param_name
        param = EyecueIpayout::ServiceParam.new(param_name,
                                                expected_type,
                                                required)
        @parameters[param_name] = param
      end
    end
  end
end
