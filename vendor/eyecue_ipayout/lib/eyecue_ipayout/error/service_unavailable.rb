require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 503
  class Error::ServiceUnavailable < EyecueIpayout::Error; end
end

