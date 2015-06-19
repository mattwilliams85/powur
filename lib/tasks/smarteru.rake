namespace :powur do
  desc 'Update smarteru enrollment state'
  task smarteru_reports: :environment do
    # Get all incomplete enrollments since 30 days ago
    ProductEnrollment
      .joins(:product)
      .incomplete
      .where('product_enrollments.created_at >=  ?', 30.days.ago)
      .find_each do |enrollment|
      begin
        report = enrollment.user.smarteru.enrollment(enrollment.product)
        process_enrollment(report, enrollment)
      rescue => e
        Airbrake.notify(e)
      end
    end
  end

  def process_enrollment(report, enrollment)
    log_message = "smarteru_reports enrollment##{enrollment.id}"

    unless report
      Rails.logger.info("#{log_message} report does not exist")
      return
    end

    if report[:completed_date]
      Rails.logger.info("#{log_message} complete")
      enrollment.complete!
    elsif report[:started_date] && enrollment.enrolled?
      Rails.logger.info("#{log_message} started")
      enrollment.start!
    end
  end
end
