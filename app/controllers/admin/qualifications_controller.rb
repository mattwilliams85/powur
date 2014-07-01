module Admin

  class QualificationsController < AdminController

    before_filter :fetch_rank

    def create
      require_input :type

      rank.qualifcations.create(input)

      render 'ranks/show'
    end

    def update
    end

    def delete
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
      @rank = Product.find(params[:rank_id])
    end

  end

end