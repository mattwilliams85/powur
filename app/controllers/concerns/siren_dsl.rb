module SirenDSL
  extend ActiveSupport::Concern

  included do
    helper_method :action, :actions
  end

  protected

  def action(name, method, href)
    actions << Action.new(name, t("actions.#{name}"), method, href)
  end

  def actions
    @actions ||= []
  end
end