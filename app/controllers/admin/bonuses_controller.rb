module Admin

  class BonusesController < AdminController

    def create
      require_input :type

      @bonus = Bonus.create!(input.merge(type: bonus_klass.name))

      render 'show'
    end

    def show
    end

    private

    def input
      allow_input(:period, :product_id, amounts: [])
    end

    def bonus_klass
      Bonus.symbol_to_type(params[:type])
    end

  end

end