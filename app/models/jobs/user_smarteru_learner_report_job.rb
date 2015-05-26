class Jobs::UserSmarteruLearnerReportJob < Struct.new(:user_id, :previous_checks)
  MAX_ATTEMPTS = 100

  def perform
    self.previous_checks ||= 0
    user = User.find(user_id)
    enrollments = user.product_enrollments.joins(:product).incomplete.to_a

    return if enrollments.empty?

    reports = user.smarteru_learner_reports
    unless reports
      enrollments.first.start_learner_report_polling(previous_checks) # enqueue new job
      raise "SmarterU API request error, user_id: #{user_id}"
    end

    enrollments.each do |enrollment|
      report = find_matching_report(reports, enrollment.product.name)
      process_enrollment(report, enrollment)
    end
  end

  # Delayed::Job max_attempts config override, don't confuse with our MAX_ATTEMPTS
  def max_attempts
    2
  end

  def find_matching_report(reports, course_name)
    reports.find { |report| report[:course_name] == course_name }
  end

  def process_enrollment(report, enrollment)
    return enrollment.remove! if report.nil?

    if report[:completed_date]
      enrollment.complete!
    elsif report[:started_date] && enrollment.enrolled?
      enrollment.start!
    else
      self.previous_checks += 1
      if previous_checks < MAX_ATTEMPTS
        enrollment.start_learner_report_polling(previous_checks) # enqueue new job
      end
    end
  end
end
