module Admin

  class RanksController < AdminController

    def index
      @ranks = Rank.all.includes(:qualifications).order(:id)
    end

    def show
    end

    def create
      
      render 'show'
    end

    def update
    end

    def destroy
    end

  end

end