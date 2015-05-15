# Javascripts
Rails.application.config.assets.precompile += %w(
  main.js
  admin.js
  modernizr/modernizr.js)

# Stylesheets
Rails.application.config.assets.precompile += [
  'admin.css'
]

