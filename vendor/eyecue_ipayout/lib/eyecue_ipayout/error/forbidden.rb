require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 403
  class Error::Forbidden < EyecueIpayout::Error; end
end

