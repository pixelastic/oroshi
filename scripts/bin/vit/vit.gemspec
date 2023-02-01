require File.join(File.dirname(__FILE__), 'lib/version.rb')

Gem::Specification.new do |gem|
  # Required attributes
  gem.name = 'vit'
  gem.summary = 'Vim-inspired aliases for your git commands'
  gem.version = GitHelper::VERSION

  # Recommended attributes
  gem.authors = ['Tim Carry']
  gem.description = 'Vim-inspired aliases for your git commands'
  gem.email = 'tim@pixelastic.com'
  gem.homepage = 'https://github.com/pixelastic/vit'
  gem.licenses = ['MIT']

  # Dependencies
  gem.add_development_dependency 'awesome_print', '~> 1.9'
  gem.add_development_dependency 'flay', '~> 2.6'
  gem.add_development_dependency 'flog', '~> 4.3'
  gem.add_development_dependency 'guard', '~> 2.16'
  gem.add_development_dependency 'guard-rspec', '~> 4.6'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop', '~> 0.51'
  gem.add_development_dependency 'rubocop-rspec-focused', '~> 0.1.0'
  gem.add_development_dependency 'simplecov', '~> 0.10'

  # Files
  gem.files = Dir[
    'bin/*',
    'lib/**/*.rb',
    'README.md',
    'CONTRIBUTING.md',
    'LICENSE.txt',
  ]
end
