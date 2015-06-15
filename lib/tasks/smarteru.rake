namespace :powur do
  task smarteru_reports: :environment do
    def find_matching_report(reports, course_name)
      return nil unless reports
      reports.select do |report|
        report[:course_name] == course_name
      end.sort_by do |report|
        report[:completed_date] ? 0 : (report[:started_date] ? 1 : 2)
      end.first
    end

    def process_enrollment(report, enrollment)
      if report && report[:completed_date]
        enrollment.complete!
      elsif report && report[:started_date] && enrollment.enrolled?
        enrollment.start!
      end
    end

    # Get all incomplete enrollments since 30 days ago
    ProductEnrollment.joins(:product).incomplete.where('product_enrollments.created_at >=  ?', 30.days.ago).find_each do |enrollment|
      report = find_matching_report(enrollment.user.smarteru_learner_reports, enrollment.product.name)
      process_enrollment(report, enrollment)
    end
  end
end
