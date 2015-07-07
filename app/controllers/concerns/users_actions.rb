module UsersActions
  extend ActiveSupport::Concern

  included do
    before_action :fetch_user,
                  only: [ :show,
                          :downline,
                          :upline,
                          :sponsors,
                          :move,
                          :eligible_parents ]
  end

  def index
    @users = apply_list_query_options(list_query)

    render 'index'
  end

  def downline
    @list_query = User.with_parent(@user.id)

    index
  end

  def upline
    @list_query = @user.upline_users

    index
  end

  def sponsors
    @users = [ @user.sponsor, @user.sponsor.sponsor]

    render 'sponsors'
  end

  def search
    @list_query = list_query.search(params[:search])

    index
  end

  def show
  end

  private

  def list_query
    @list_query ||= User.with_parent(current_user.id)
  end
end
