namespace :powur do
  def refresh_enrollment(enrollment)
    enrollment.refresh_enrollment_status
  rescue => e
    Airbrake.notify(e)
  end

  desc 'Update smarteru enrollment state'
  task smarteru_reports: :environment do
    ProductEnrollment.need_status_refresh.each do |enrollment|
      refresh_enrollment(enrollment)
    end
  end
end
