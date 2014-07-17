module Admin

  class BonusesController < AdminController

    before_filter :fetch_requirement, except: [ :create ]

    def create
      @bonus.requirements.create!(input)

      render 'admin/bonuses/show'
    end

    def update
      @requirement.update_attributes!(input)

      render 'admin/bonuses/show'
    end

    def destroy
      @requirement.destroy

      render 'admin/bonuses/show'
    end

    private

    def input
      allow_input(:product_id, :quantity, :source)
    end

    def fetch_bonus
      @bonus = Bonus.includes(:requirements).find(params[:bonus_id].to_i)
    end

    def fetch_requirement
      @requirement = @bonus.requirements.find(params[:id].to_i)
    end

  end
end