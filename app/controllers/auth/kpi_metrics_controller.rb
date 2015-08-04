module Auth
  class KpiMetricsController < AuthController
    page max_limit: 8

    def show
      @user = current_user
      user_ids = User.all_team(@user.id).pluck(:id)
      @proposal_count = Lead.where(user_id: user_ids).converted.count
      @team_count = user_ids.size - 1
    end

    def proposals_show
      @user = User.find(params[:id])
      scale = params[:scale].to_i + 1
      @orders = @user.leads.contracted(from: scale.days.ago)
      @proposals = @user.leads.converted(from: scale.days.ago)

      render 'auth/kpi_metrics/proposals/show'
    end

    def genealogy_show
      @user = User.find(params[:id])
      scale = params[:scale].to_i + 1
      @downline = User.with_ancestor(@user.id)
        .where('created_at >= ?', scale.days.ago)

      render 'auth/kpi_metrics/genealogy/show'
    end
  end
end
