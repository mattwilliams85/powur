class UserGroupRequirement < ActiveRecord::Base
  belongs_to :user_group
  belongs_to :product

  enum time_span: { monthly: 1, lifetime: 2 }
  enum event_type: { course_completion: 1, personal_sales: 2, group_sales: 3 }

  validates_presence_of :user_group_id, :product_id, :event_type, :quantity

  def qualified_user_ids
    course_completion? ? course_completed_user_ids : sales_met_user_ids
  end

  private

  def course_completed_user_ids
    ProductEnrollment.where(product_id: product_id).completed.pluck(:user_id)
  end

  def sales_met_user_ids
    period_id = MonthlyPayPeriod.current.id
    totals = OrderTotal.where(product_id:    product_id,
                              pay_period_id: period_id)
    quantity_column = personal_sales? ? 'personal' : 'group'
    quantity_column +=  '_lifetime' unless monthly?
    totals.where("\"#{quantity_column}\" >= ?", quantity).pluck(:user_id)
  end

end
