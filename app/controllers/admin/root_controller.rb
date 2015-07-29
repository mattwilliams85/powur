module Admin
  class RootController < AdminController
    layout 'admin'

    def index
      respond_to do |format|
        format.html
        format.json do
          # Currently 'America/Los_Angeles' is not set as default timezone
          # using in_time_zone for the admin dashboard
          since = Time.zone.now.utc
            .in_time_zone('America/Los_Angeles')
            .at_beginning_of_day
          since -= (params[:days_ago].to_i - 1).days if params[:days_ago]

          @stats_items = [
            { name: 'Leads', value: submitted_quotes_count(since) },
            { name: 'Certifications', value: purchases_count(since) },
            { name: 'Certification Revenue', value: '$' + purchases_revenue(since).to_s },
            { name: 'Final Contracts', value: quote_contracts_count(since) },
            { name: 'New Advocates', value: users_count(since) }
          ]
        end
      end
    end

    private

    def submitted_quotes_count(since)
      Quote.where(['submitted_at > ?', since.to_s(:db)]).count
    end

    def quote_contracts_count(since)
      Quote
        .joins(:lead_updates)
        .where(['lead_updates.contract > ?', since.to_s(:db)])
        .map(&:id).uniq.length
    end

    def purchases_count(since)
      ProductReceipt.where(['created_at > ? AND amount > 0', since.to_s(:db)])
        .count
    end

    def purchases_revenue(since)
      ProductReceipt.connection
        .execute("SELECT SUM(amount) FROM product_receipts WHERE created_at > '#{since.to_s(:db)}'")
        .first['sum'].to_i / 100
    end

    def users_count(since)
      User.where(['created_at > ?', since.to_s(:db)]).count
    end
  end
end
