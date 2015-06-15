class Jobs::UserSmarteruLearnerReportJob < Struct.new(:user_id, :previous_checks)
  def perform
    user = User.find(user_id)
    # Get incomplete enrollments for the user since 30 days ago
    enrollments = user.product_enrollments.joins(:product).incomplete.where('product_enrollments.created_at >=  ?', 30.days.ago).to_a

    return if enrollments.empty?

    reports = user.smarteru_learner_reports
    enrollments.each do |enrollment|
      report = find_matching_report(reports, enrollment.product.name)
      process_enrollment(report, enrollment)
    end
  end

  def max_attempts
    2
  end

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
    else
      enrollment.start_learner_report_polling # enqueue new job
    end
  end
end
