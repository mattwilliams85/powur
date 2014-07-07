module Admin

  class QualificationsController < AdminController

    before_filter :fetch_rank
    before_filter :fetch_qualification, only: [ :update, :destroy ]

    def create
      require_input :type

      @rank.qualifications.create!(input)

      render 'admin/ranks/show'
    end

    def update
    end

    def destroy
      @rank.qualifications.delete(@qualification)

      render 'admin/ranks/show'
    end

    private

    def input
      allow_input(:name, :period, :quantity, :max_leg_percent).
        merge(type: qualification_klass.name)
    end

    def qualification_klass
      Qualification.symbol_to_type(params[:type])
    end

    def fetch_rank
      @rank = Rank.find(params[:rank_id].to_i)
    end

    def fetch_qualification
      @qualification = @rank.qualifications.find(params[:id].to_i)
    end

  end

end