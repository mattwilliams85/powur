module Admin

  class RequirementsController < AdminController

    before_action :fetch_bonus
    before_action :fetch_requirement, except: [ :create ]

    def create
      @bonus.requirements.create!(input)

      render 'show'
    end

    def update
      @requirement.update_attributes!(input)
      @bonus.requirements.reload

      render 'show'
    end

    def destroy
      @requirement.destroy
      @bonus.requirements.reload

      render 'show'
    end

    private

    def input
      allow_input(:product_id, :quantity, :source)
    end

    def fetch_bonus
      @bonus = Bonus.includes(:requirements, :bonus_levels).find(params[:bonus_id].to_i)
    end

    def fetch_requirement
      @requirement = @bonus.requirements.find([ @bonus.id, params[:id].to_i ])
    end

    def controller_path
      'admin/bonuses'
    end

  end
end