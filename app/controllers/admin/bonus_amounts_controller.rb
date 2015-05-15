module Admin
  class BonusAmountsController < AdminController
    before_action :fetch_bonus, only: [ :create ]
    before_action :fetch_bonus_amount, except: [ :create ]

    def create
      error!(:cannot_add_amounts) unless @bonus.can_add_amounts?
      @bonus_amount = @bonus.bonus_amounts.build(
        input.merge(level: @bonus.next_bonus_level))

      if @bonus_amount.exceeds_available?
        error!(:amount_exceeds_max, :amounts,
               amount: @bonus_amount.max,
               max:    @bonus.remaining_amount)
      end

      @bonus_amount.save!

      render 'show'
    end

    def update
      @bonus_amount.update_attributes!(input)

      render 'show'
    end

    def destroy
      @bonus_amount.destroy

      render 'show'
    end

    private

    def input
      allow_input(:rank_path_id, amounts: [])
    end

    def fetch_bonus
      @bonus = Bonus
        .includes(:bonus_amounts)
        .references(:bonus_amounts)
        .find(params[:bonus_id].to_i)
    end

    def fetch_bonus_amount
      @bonus_amount = BonusAmount.where(id: params[:id].to_i).includes(
        :bonus, :rank_path).references(
        :bonus, :rank_path).first
      @bonus = @bonus_amount.bonus
    end

    class << self
      def controller_path
        'admin/bonuses'
      end
    end
  end
end
