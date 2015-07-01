klass :requirement

entity_rel(local_assigns[:rel]) if local_assigns[:rel]

json.properties do
  json.call(requirement, :id, :user_group_id, :event_type, :product_id)
  json.product requirement.product.name
  unless requirement.course_enrollment?
    json.quantity requirement.quantity
    json.time_span requirement.time_span && requirement.time_span.titleize
    if requirement.group_sales?
      json.max_leg requirement.max_leg
    end
  end
end

self_link requirement_path(requirement)
