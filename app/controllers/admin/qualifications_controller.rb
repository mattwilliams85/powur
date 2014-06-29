module Admin

  class QualificationsController < AdminController

    before_filter :fetch_rank

    def create
      require_input :type

      qualification_klass
    end

    def udpate
    end

    def delete
    end

    private

    def input

    end

    def qualification_klass
      Qualification.symbol_to_type(params[:type])
    end

    def fetch_rank
      @rank = Product.find(params[:rank_id])
    end

  end

end