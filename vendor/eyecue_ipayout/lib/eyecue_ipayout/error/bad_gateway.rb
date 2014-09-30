require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 502
  class Error::BadGateway < EyecueIpayout::Error; end
end

