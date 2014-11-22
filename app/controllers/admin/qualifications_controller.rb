module Admin
  class QualificationsController < AdminController
    before_action :fetch_qualification, only: [ :update, :destroy ]

    def index
      @qualifications = Qualification.where('rank_id is null').order(:id)

      render 'index'
    end

    def create
      require_input :type

      @qualification = qualification_klass.create!(input)

      render 'show'
    end

    def update
      @qualification.update_attributes!(input)

      render 'show'
    end

    def destroy
      @qualification.destroy

      render 'index'
    end

    protected

    def input
      allow_input(:rank_path_id, :time_period, :quantity, :max_leg_percent,
                  :product_id)
    end

    def qualification_klass
      Qualification.symbol_to_type(params[:type])
    end

    def fetch_qualification
      @qualification = Qualification.includes(
        :product).references(:product).find(params[:id].to_i)
    end
  end
end
