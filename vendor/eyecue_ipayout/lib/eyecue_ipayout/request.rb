module EyecueIpayout
  module Request
    def get(path, params = {}, options = {})
      #request(:get, path, params, options)
      connection.get(path, params).body
    end

    def post(path, params = {}, options = {})
      #request(:post, path, params, options)
      response = connection.post(path, params, options).body
    end

    private
  end
end
