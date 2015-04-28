# Javascripts
Rails.application.config.assets.precompile += [
  'admin.js',
  'modernizr/modernizr.js'
]

Rails.application.config.assets.precompile += %w( earnings.js )
Rails.application.config.assets.precompile += %w( creditly.js )
Rails.application.config.assets.precompile += %w( dashboard.js )
Rails.application.config.assets.precompile += %w( dashboard-topper.js )
Rails.application.config.assets.precompile += %w( kpi.js )
Rails.application.config.assets.precompile += %w( profile.js )
Rails.application.config.assets.precompile += %w( promoter.js )
Rails.application.config.assets.precompile += %w( quote.js )
Rails.application.config.assets.precompile += %w( user.js )
Rails.application.config.assets.precompile += %w( jquery.pagepiling.js )

Rails.application.config.assets.precompile += [
  'new/application.js',
  'new/admin.js'
]

# Vendor Javascripts
Rails.application.config.assets.precompile += %w( Chart.js )
Rails.application.config.assets.precompile += %w( vendor/modernizr.js )

# Stylesheets
Rails.application.config.assets.precompile += [
  'admin.css'
]

