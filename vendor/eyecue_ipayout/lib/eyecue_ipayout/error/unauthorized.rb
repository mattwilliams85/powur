require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 401
  class Error::Unauthorized < EyecueIpayout::Error; end
end

