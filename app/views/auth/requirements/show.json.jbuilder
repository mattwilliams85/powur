siren json

json.partial! 'item', requirement: @requirement

if admin?
  update = action(:update, :patch, requirement_path(@requirement))
  unless @requirement.purchase?
    update
      .field(:quantity, :integer, required: true, value: @requirement.quantity)
      .field(:time_span, :select,
             options:  UserGroupRequirement.enum_options(:time_spans),
             required: true,
             value:    @requirement.time_span)
    if @requirement.grid_sales?
      update.field(:max_leg, :integer,
                   required: false,
                   value:    @requirement.value)
    end
  end
  actions(update, action(:delete, :delete, requirement_path(@requirement)))
end
