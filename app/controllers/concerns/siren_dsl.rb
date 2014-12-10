module SirenDSL
  extend ActiveSupport::Concern

  def confirm(value, args = {})
    message confirm: value.is_a?(Symbol) ? t("confirms.#{value}", args) : value
  end

  def message(value) # rubocop:disable Style/TrivialAccessors
    @message = value
  end
end
