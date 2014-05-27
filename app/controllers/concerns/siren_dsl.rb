module SirenDSL
  extend ActiveSupport::Concern

  included do
    helper_method :action, :actions, :klass
  end

  protected

  def klass(value = nil)
    @klass ||= value
  end

  def action(name, method, href)
    (actions << Action.new(name, t("actions.#{name}"), method, href)).last
  end

  def actions
    @actions ||= []
  end
end