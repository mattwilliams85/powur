require 'eyecue_ipayout/error'

module EyecueIpayout
  # Raised when EyecueIpayout returns the HTTP status code 406
  class Error::NotAcceptable < EyecueIpayout::Error; end
end

