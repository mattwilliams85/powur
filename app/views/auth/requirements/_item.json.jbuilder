klass :requirement

entity_rel(local_assigns[:rel]) if local_assigns[:rel]

json.properties do
  json.call(requirement, :id, :user_group_id, :event_type, :product_id)
  json.product requirement.product.name
  unless requirement.purchase?
    json.quantity requirement.quantity
    json.time_span requirement.time_span && requirement.time_span.titleize
    json.max_leg(requirement.max_leg) if requirement.group_sales?
  end
  json.progress(requirement.progress_for(@user)) if @user
end

self_link requirement_path(requirement)
