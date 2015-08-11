module Admin
  class RootController < AdminController
    layout 'admin'

    before_action :set_date_since, :set_date_until, only: [ :index ]

    # TODO: set timezone on the app configuration
    TIMEZONE = 'America/Los_Angeles'

    def index
      respond_to do |format|
        format.html
        format.json do
          @stats_items = [
            { name: 'Leads', value: submitted_leads_count },
            { name: 'Certifications', value: purchases_count },
            { name: 'Certification Revenue', value: "$#{purchases_revenue}" },
            { name: 'Final Contracts', value: contracted_leads_count },
            { name: 'New Advocates', value: users_count }
          ]
        end
      end
    end

    private

    def submitted_leads_count
      Lead.submitted(from: @date_since, to: @date_until).count
    end

    def contracted_leads_count
      Lead.contracted(from: @date_since, to: @date_until).count
    end

    def purchases_count
      ProductReceipt.where(['purchased_at > ? AND purchased_at < ?',
                            @date_since, @date_until])
        .count
    end

    def purchases_revenue
      ProductReceipt.connection
        .execute('SELECT SUM(amount) FROM product_receipts WHERE ' \
          "purchased_at > '#{@date_since}' AND " \
          "purchased_at < '#{@date_until}'")
        .first['sum'].to_i / 100
    end

    def users_count
      User.where(['created_at > ? AND created_at < ?',
                  @date_since, @date_until]).count
    end

    def set_date_since
      if params[:date_since]
        @date_since = (Time.zone.parse(params[:date_since])
          .in_time_zone(TIMEZONE).at_beginning_of_day + 1.day).to_s(:db)
      else
        @date_since = (Time.zone.now.in_time_zone(TIMEZONE)
          .at_beginning_of_day).to_s(:db)
      end
    end

    def set_date_until
      if params[:date_until]
        @date_until = (Time.zone.parse(params[:date_until])
          .in_time_zone(TIMEZONE).at_beginning_of_day + 2.days).to_s(:db)
      else
        @date_until = (Time.zone.now.in_time_zone(TIMEZONE)).to_s(:db)
      end
    end
  end
end
