# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'kitchen/verifier/goss_version'

Gem::Specification.new do |gem|
  gem.name              = "kitchen-goss"
  gem.version           = Kitchen::Verifier::GOSS_VERSION
  gem.authors           = ["Adham Helal"]
  gem.email             = ["adham.helal@gmail.com"]
  gem.licenses          = ['MIT']
  gem.homepage          = "https://github.com/ahelal/kitchen-goss"
  gem.summary           = "A test-kitchen verifier plugin for GOSS"
  candidates            = Dir.glob("{lib}/**/*") + ['README.md', 'kitchen-goss.gemspec']
  gem.files             = candidates.sort
  gem.platform          = Gem::Platform::RUBY
  gem.require_paths     = ['lib']
  gem.rubyforge_project = '[none]'
  gem.description       = <<-EOF
== DESCRIPTION:
GOSS is a tool for validating a server's configuration. 
This kitchen plugin adds Goss support as a validation to test-kitchen.

== FEATURES:


EOF

  gem.add_runtime_dependency 'test-kitchen'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'

end