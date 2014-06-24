module ParamValidation
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :active_record_error
    rescue_from ::Errors::InputError, ::Errors::AlertError, with: :render_json_error
  end

  protected

  def allow_input(*keys)
    Hash[params.permit(*keys).map { |k,v| [ k, v.presence ] }]
  end

  def try_input_error(value, arg_name)
    if value.blank?
      msg = t('errors.required', input: arg_name)
      raise ::Errors::InputError.new(arg_name), msg
    end
  end

  def require_input(*args)
    embedded_args = args.last.kind_of?(Hash) ? args.pop : {}
    args.each  { |arg| try_input_error(params[arg], arg) }
    embedded_args.each do |key, args|
      args.each do |arg|
        try_input_error(params[key][arg], "#{key}[#{arg}]")
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

  def not_found!(entity, id = params[:id])
    error!(t('errors.not_found', entity: entity, id: id))
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