# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
#Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += [
  '*.svg',
  '*.eot',
  '*.woff',
  '*.woff2',
  '*.ttf',
  '**/engine.js',
  '**/engine.css',
  '**/engine_*.js',
  '**/engine_*.css',
  '**/module.js',
  '**/module.css',
  '**/module_*.js',
  '**/module_*.css',
]
