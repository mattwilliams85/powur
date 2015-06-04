module Admin
  class ApplicationAgreementsController < AdminController
    before_action :fetch_agreement, only: [ :show, :destroy, :publish, :unpublish ]

    page max_limit: 10

    def index
      scope = ApplicationAgreement.sorted
      @agreements = apply_list_query_options(scope)
    end

    def create
      require_input :version, :document_path
      @agreement = ApplicationAgreement.create!(input)

      render :show
    end

    def destroy
      @agreement.destroy

      head 200
    end

    def publish
      @agreement.update_attribute(:published_at, Time.now)

      render :show
    end

    def unpublish
      @agreement.update_attribute(:published_at, nil)

      render :show
    end

    private

    def input
      allow_input(:version, :document_path, :message)
    end

    def fetch_agreement
      @agreement = ApplicationAgreement.find(params[:id].to_i)
    end
  end
end
