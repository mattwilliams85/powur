module SirenDSL
  extend ActiveSupport::Concern

  def confirm(value, args = {})
    message confirm: value.is_a?(Symbol) ? t("confirms.#{value}", args) : value
  end

  # rubocop:disable Style/TrivialAccessors
  def message(value)
    @message = value
  end
end
