module Paperclip
  # Workaround Details:
  # https://github.com/thoughtbot/paperclip/issues/1470
  # http://robots.thoughtbot.com/prevent-spoofing-with-paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
