namespace :powur do
  task smarteru_reports: :environment do
    def process_enrollment(report, enrollment)
      if report && report[:completed_date]
        enrollment.complete!
      elsif report && report[:started_date] && enrollment.enrolled?
        enrollment.start!
      end
    end

    # Get all incomplete enrollments since 30 days ago
    ProductEnrollment.joins(:product).incomplete.where('product_enrollments.created_at >=  ?', 30.days.ago).find_each do |enrollment|
      report = enrollment.user.smarteru.enrollment(enrollment.product)
      process_enrollment(report, enrollment)
    end
  end
end
