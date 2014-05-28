module SirenDSL
  extend ActiveSupport::Concern

  included do
    helper_method :klass, :action, :actions, :entity, :entities, :resource
  end

  attr_reader :entity

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

  def entities(value = nil)
    @entities ||= value || []
  end
end