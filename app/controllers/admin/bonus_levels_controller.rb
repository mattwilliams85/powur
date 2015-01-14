module Admin
  class BonusLevelsController < AdminController
    before_action :fetch_bonus, only: [ :create ]
    before_action :fetch_bonus_level, except: [ :create ]

    def create
      error!(:cannot_add_amounts) unless @bonus.can_add_amounts?(all_paths.size)
      clear_level(@bonus.next_bonus_level) unless rank_path_input?

      @bonus_level = @bonus.bonus_levels.create!(
        input.merge(level: @bonus.next_bonus_level))

      fill_level if rank_path_input?

      render 'show'
    end

    def update
      @bonus_level.update_attributes!(input)

      render 'show'
    end

    def destroy
      clear_level(@bonus_level.level)

      render 'show'
    end

    private

    def clear_level(level)
      @bonus.bonus_levels.where(level: level).destroy_all
    end

    def fill_level
      level_id = @bonus.highest_bonus_level
      all_paths.reject { |p| p.id == params[:rank_path_id] }.each do |path|
        exists = @bonus.bonus_levels.any? do |bl|
          bl.level == level_id && bl.rank_path_id == path.id
        end
        next if exists
        @bonus.bonus_levels.create!(
          level:        level_id,
          rank_path_id: path.id,
          amounts:      Array.new(all_paths.size, BigDecimal.new('0')))
      end
    end

    def rank_path_input?
      params[:rank_path_id].present?
    end

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

    class << self
      def controller_path
        'admin/bonuses'
      end
    end
  end
end
