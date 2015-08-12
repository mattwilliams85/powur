class ApplicationController < ActionController::Base
  include SirenDSL
  include ListQuery

  helper_method :current_user, :all_ranks, :all_paths, :all_products, :admin?

  protected

  def current_user
    fail NotImplementedError
  end

  def all_ranks
    @all_ranks ||= Rank.preloaded
  end

  def all_products
    @all_products ||= Product.all.order(:name)
  end
end
