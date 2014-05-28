module ParamValidation
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :active_record_error
    rescue_from ::Errors::InputError, ::Errors::AlertError, with: :render_json_error
  end

  protected

  def require_input(*args)
    args.each do |arg|
      if params[arg].blank?
        raise ::Errors::InputError.new(arg), t('errors.required', input: arg)
      end
    end
  end

  def error!(msg, field = nil)
    if field
      raise ::Errors::InputError.new(field), msg
    else
      raise ::Errors::AlertError, msg
    end
  end

  def active_record_error(e)
    raise ::Errors::InputError.new(e.record.errors.first.first), e.message
  rescue ::Errors::InputError => e
    render_json_error(e)
  end

  def render_json_error(e)
    respond_to do |format|
      format.html { render text: e.message }
      format.json { render json: e.as_json }
    end
  end
end