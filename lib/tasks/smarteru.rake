namespace :powur do
  desc 'Update smarteru enrollment state'
  task smarteru_reports: :environment do
    # Get all incomplete enrollments since 30 days ago
    ProductEnrollment.joins(:product).incomplete.where('product_enrollments.created_at >=  ?', 30.days.ago).find_each do |enrollment|
      begin
        report = enrollment.user.smarteru.enrollment(enrollment.product)
        process_enrollment(report, enrollment)
      rescue => e
        Airbrake.notify(e)
      end
    end
  end

  def process_enrollment(report, enrollment)
    unless report
      Rails.logger.info("smarteru_reports enrollment##{enrollment.id} report does not exist")
      return
    end

    if report[:completed_date]
      Rails.logger.info("smarteru_reports enrollment##{enrollment.id} complete")
      enrollment.complete!
    elsif report[:started_date] && enrollment.enrolled?
      Rails.logger.info("smarteru_reports enrollment##{enrollment.id} started")
      enrollment.start!
    end
  end
end
