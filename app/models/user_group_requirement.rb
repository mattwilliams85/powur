class UserGroupRequirement < ActiveRecord::Base
  belongs_to :user_group
  belongs_to :product

  enum time_span: { monthly: 1, lifetime: 2 }
  enum event_type: { course_completion: 1, personal_sales: 2, group_sales: 3 }

  validates_presence_of :user_group_id, :product_id, :event_type, :quantity

  def qualified_user_ids
    course_completion? ? course_completed_user_ids : sales_met_user_ids
  end

  def user_qualified?(user_id)
    course_completion? ? user_completed_course?(user_id) : user_met_sales?(user_id)
  end

  private

  def completed_enrollments
    ProductEnrollment.where(product_id: product_id).completed
  end

  def order_total_quantity_column
    name = personal_sales? ? 'personal' : 'group'
    name +=  '_lifetime' unless monthly?
    name
  end

  def qualified_order_totals
    @order_totals ||= begin
      period_id = MonthlyPayPeriod.current.id
      OrderTotal.where(product_id:    product_id,
                       pay_period_id: period_id)
                .where("\"#{order_total_quantity_column}\" >= ?", quantity)
    end
  end

  def course_completed_user_ids
    completed_enrollments.pluck(:user_id)
  end

  def user_completed_course?(user_id)
    completed_enrollments.where(user_id: user_id).exists?
  end

  def sales_met_user_ids
    qualified_order_totals.pluck(:user_id)
  end

  def user_met_sales?(user_id)
    qualified_order_totals.where(user_id: user_id).exists?
  end
end
