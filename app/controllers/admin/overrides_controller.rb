module Admin
  class OverridesController < AdminController
    sort start_date: :start_date,
         user:       'users.last_name asc, users.first_name asc'

    def index
    end

    def create
    end

    def update
    end

    def destroy
    end
  end
end
