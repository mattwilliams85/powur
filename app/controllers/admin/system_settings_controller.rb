module Admin
  class SystemSettingsController < AdminController
    before_action :fetch_setting, only: [ :show, :update ]

    def index
      @system_settings = SystemSettings.editable.sorted.all
    end

    def update
      @system_setting.update_attributes!(value: formatted_value)

      render :show
    end

    private

    def fetch_setting
      @system_setting = SystemSettings.editable.find(params[:id].to_i)
    end

    # Return value in a proper data type
    def formatted_value
      value = params[:value].to_s
      case value
      when value.to_i.to_s
        value.to_i
      when value.to_f.to_s
        value.to_f
      when 'true', 'false'
        value == 'true'
      else
        value
      end
    end
  end
end
