class AugOverrides < ActiveRecord::Migration
  def change
    return if Rails.env.test?
    Rake::Task['powur:overrides:sponsors'].invoke
    user = User.find_by(id: 1519)
    user && user.destroy!
  end
end
