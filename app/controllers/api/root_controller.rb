module Api
  class RootController < ApiController
    skip_before_action :authenticate!

    VALID_API_RANGE = (1..1)

    def show
      return unless params[:v] && !VALID_API_RANGE.cover?(params[:v].to_i)
      api_error!(:invalid_scope, v: params[:v])
    end
  end
end
