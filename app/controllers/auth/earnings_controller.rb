module Auth
  class EarningsController < AuthController
    def show
      render 'show.html.erb'
    end
  end
end
