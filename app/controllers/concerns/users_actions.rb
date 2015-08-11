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
    # before_action :fetch_user,
    #               only: [ :show, :downline, :upline, :move, :eligible_parents ]

    # filter :performance,
    #        fields:     { metric: { options: [ :quote_count,
    #                                           :personal_sales,
    #                                           :grid_sales ],
    #                                heading: :order_by },
    #                      period: { options: [ :lifetime, :monthly, :weekly ],
    #                                heading: :for_period } },
    #        scope_opts: { type: :hash, using: [ :metric, :period ] }

  end

  # def index
  #   @users = apply_list_query_options(list_query)

  #   render 'index'
  # end

  # def downline
  #   @list_query = User.with_parent(@user.id)

  #   index
  # end

  # def upline
  #   @list_query = @user.upline_users

  #   index
  # end

  # def sponsors
  #   @users = [ @user.sponsor, @user.sponsor.try(:sponsor) ].compact
  #   render 'sponsors'
  # end

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
