# Javascripts
Rails.application.config.assets.precompile += %w(
  admin.js
  modernizr/modernizr.js)

# Stylesheets
Rails.application.config.assets.precompile += [
  'admin.css'
]

Rails.application.config.assets.precompile += %w( client.css )
Rails.application.config.assets.precompile += %w( client.js )
Rails.application.config.assets.precompile += %w( assets/img/default-profile.png )
