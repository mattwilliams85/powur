require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 400
  class Error::BadRequest < EyecueIpayout::Error; end
end

