module Auth
  class KpiMetricsController < AuthController
    page max_limit: 8

    def show
      @user = current_user
      @proposal_count = Lead.team_count(user_id: @user.id, query: Lead.submitted)
      @team_count = User.with_ancestor(@user.id).count
      @co2_count = co2_calc.round
    end

    def proposals_show
      @user = User.find(params[:id])
      scale = params[:scale].to_i + 1
      @leads = @user.leads.submitted(from: scale.days.ago)
      @proposals = @user.leads.converted(from: scale.days.ago)
      @closed = @user.leads.closed_won(from: scale.days.ago)
      @contracts = @user.leads.contracted(from: scale.days.ago)
      @installs = @user.leads.installed(from: scale.days.ago)

      render 'auth/kpi_metrics/proposals/show'
    end

    def proposals_show_team
      @user = User.find(params[:id])
      scale = params[:scale].to_i + 1
      @leads = Lead.team_leads(user_id: @user.id, query: Lead.submitted(from: scale.days.ago))
      @proposals = Lead.team_leads(user_id: @user.id, query: Lead.converted(from: scale.days.ago))
      @closed = Lead.team_leads(user_id: @user.id, query: Lead.closed_won(from: scale.days.ago))
      @contracts = Lead.team_leads(user_id: @user.id, query: Lead.contracted(from: scale.days.ago))
      @installs = Lead.team_leads(user_id: @user.id, query: Lead.installed(from: scale.days.ago))
      render 'auth/kpi_metrics/proposals/show'
    end

    def genealogy_show_team
      @user = User.find(params[:id])
      scale = params[:scale].to_i + 1
      @downline = User.with_ancestor(@user.id)
        .where('created_at >= ?', scale.days.ago)

      render 'auth/kpi_metrics/genealogy/show'
    end

    def co2_calc
      lb = 0
      homes = User.installations(@user.id).pluck(:installed_at)
      homes.each do |home|
        lb += (Time.now - home) / 1.days * 1.067
      end
      lb * 1000
    end
  end
end
