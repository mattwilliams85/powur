module Admin

  class QuotesController < AdminController

    def index
      @quotes = Quote.order(:created_at).limit(limit).offset(offset)

      render 'index'
    end

    private

    def limit
      @limit ||= params[:limit] ? params[:limit].to_i : 20
    end

    def offset
      @offset ||= params[:p] ? limit * (params[:p].to_i - 1) : 0
    end

  end
end
