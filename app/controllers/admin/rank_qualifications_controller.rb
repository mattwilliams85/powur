module Admin

  class RankQualificationsController < QualificationsController

    before_action :fetch_rank

    def create
      require_input :type

      @rank.qualifications.create!(input.merge(type: qualification_klass.name))

      render 'admin/ranks/show'
    end

    def update
      @qualification.update_attributes!(input)

      render 'admin/ranks/show'
    end

    def destroy
      @qualification.destroy

      render 'admin/ranks/show'
    end

    private

    def fetch_rank
      @rank = Rank.find(params[:rank_id].to_i)
    end

  end

end