class ApplicationController < ActionController::Base
  include SirenDSL
  include ListQuery
  # helper SirenJson

  helper_method :current_user, :all_ranks, :all_paths, :all_products, :admin?

  protected

  def current_user
    fail NotImplementedError
  end

  def all_ranks
    @all_ranks ||= begin
      Rank.all
        .includes(:qualifications)
        .references(:qualifications)
    end
  end

  def all_paths
    @all_paths ||= RankPath.all.order(:name)
  end

  def all_products
    @all_products ||= Product.all.order(:name)
  end

  def fetch_downline_user(user_id)
    return current_user if user_id == current_user.id
    User.with_ancestor(current_user.id).where(id: user_id.to_i).first ||
      not_found!(:user, user_id)
  end
end
