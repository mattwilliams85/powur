module Admin
  class BonusLevelsController < AdminController
    before_action :fetch_bonus, only: [ :create ]
    before_action :fetch_bonus_level, except: [ :create ]

    def create
      @bonus_level = @bonus.bonus_levels.create!(
        input.merge(level: @bonus.next_bonus_level))

      render 'show'
    end

    def update
      @bonus_level.update_attributes!(input)

      render 'show'
    end

    def destroy
      @bonus_level.destroy
      @bonus.bonus_levels.reload

      render 'show'
    end

    private

    def input
      allow_input(:rank_path_id, amounts: [])
    end

    def fetch_bonus
      @bonus = Bonus.includes(
        :requirements, :bonus_levels).references(
        :requirements, :bonus_levels).find(
        params[:bonus_id].to_i)
    end

    def fetch_bonus_level
      @bonus_level = BonusLevel.where(id: params[:id].to_i).includes(
        :bonus, :rank_path).references(
        :bonus, :rank_path).first
      @bonus = @bonus_level.bonus
    end

    def controller_path
      'admin/bonuses'
    end
  end
end
