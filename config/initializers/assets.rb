# Javascripts
Rails.application.config.assets.precompile += [
  'admin/admin.js',
  'admin/products.js',
  'admin/quotes.js',
  'admin/notifications.js'
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
  'new/application.js'
]

# Vendor Javascripts
Rails.application.config.assets.precompile += %w( Chart.js )

# Stylesheets
Rails.application.config.assets.precompile += [
  'admin/users.css',
  'admin/notifications.css'
]
Rails.application.config.assets.precompile += %w( creditly.css )
Rails.application.config.assets.precompile += %w( index.css )
Rails.application.config.assets.precompile += %w( profile.css )
Rails.application.config.assets.precompile += %w( promoter.css )
Rails.application.config.assets.precompile += %w( user.css )
Rails.application.config.assets.precompile += %w( earnings.css )
Rails.application.config.assets.precompile += %w( kpi.css )
Rails.application.config.assets.precompile += %w( jquery.pagepiling.css )

Rails.application.config.assets.precompile += [
  'new/application.css'
]
