module Admin

  class BonusLevelsController < AdminController

    before_action :fetch_bonus
    before_action :fetch_bonus_level, except: [ :create ]

    def create

      render 'show'
    end

    def update

      render 'show'
    end

    def destroy

      render 'show'
    end

    private

    def input
      allow_input(amounts: [])
    end

    def fetch_bonus
      @bonus = Bonus.includes(:requirements, :bonus_levels).find(params[:bonus_id].to_i)
    end

    def fetch_bonus_level
      @bonus_level = @bonus.levels.find(params[:id].to_i)
    end

    def controller_path
      'admin/bonuses'
    end

  end

end