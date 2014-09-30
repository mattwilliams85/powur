require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 404
  class Error::NotFound < EyecueIpayout::Error; end
end

