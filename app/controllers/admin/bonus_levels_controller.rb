module Admin

  class BonusLevelsController < AdminController

    before_filter :fetch_bonus
    before_filter :fetch_bonus_level, except: [ :create ]

    def create

      render 'admin/bonuses/show'
    end

    def update

      render 'admin/bonuses/show'
    end

    def destroy

      render 'admin/bonuses/show'
    end

    private

    def fetch_bonus
      @bonus = Bonus.includes(:requirements, :bonus_levels).find(params[:bonus_id].to_i)
    end

    def fetch_bonus_level
      @bonus_level = @bonus.levels.find(params[:id].to_i)
    end
  end

end