require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 500
  class Error::InternalServerError < EyecueIpayout::Error; end
end

