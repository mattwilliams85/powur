# Javascripts
Rails.application.config.assets.precompile += %w(
  admin.js
  modernizr/modernizr.js)

# Stylesheets
Rails.application.config.assets.precompile += [
  'admin.css'
]

Rails.application.config.assets.precompile += %w( next.css )
Rails.application.config.assets.precompile += %w( next.js )

