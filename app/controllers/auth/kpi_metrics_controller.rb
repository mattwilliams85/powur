module Auth
  class KpiMetricsController < AuthController
    page max_limit: 8

    def show
      @user = current_user
      @proposal_count = Lead.team_count(user_id: @user.id, query: Lead.submitted)
      @team_count = User.with_ancestor(@user.id).count
      @co2_count = co2Calc.round
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

    def co2Calc
      kwh = 0
      homes = User.installations(@user.id).pluck(:installed_at)
      homes.each do |home|
        kwh += (Time.now - home)/1.days * 30
      end
      kwh * 2.07 #kwh to CO2/lb
    end
  end
end
