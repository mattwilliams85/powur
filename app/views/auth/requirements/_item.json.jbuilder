klass :requirement

entity_rel(local_assigns[:rel]) if local_assigns[:rel]

team = requirement.team?
purchase = requirement.is_a?(PurchaseRequirement)

json.properties do
  json.call(requirement, :id, :product_id, :title)

  json.team team
  json.call(requirement, :max_leg, :leg_count) if team

  json.purchase purchase
  json.call(requirement, :lead_status) unless purchase

  json.product requirement.product.name
  json.quantity requirement.quantity
  json.time_span requirement.time_span && requirement.time_span.titleize

  if @user
    progress = requirement.progress_for(@user.id, MonthlyPayPeriod.current_id)
    json.progress progress
  end
end

self_link requirement_path(requirement)
