# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omnifocus/jira/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nicholas Crown"]
  gem.email         = ["nick@thecrowns.org"]
  gem.description   = %q{Plugin for omnifocus gem to provide JIRA BTS synchronization.}
  gem.summary       = %q{Plugin for omnifocus gem to provide JIRA BTS synchronization.}
  gem.homepage      = "https://github.com/ncrown/omnifocus-jira"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "omnifocus-jira"
  gem.require_paths = ["lib"]
  gem.version       = OmniFocus::Jira::VERSION

  gem.add_dependency "omnifocus", "~> 2.1"
  gem.add_dependency "jira-ruby", "~> 0.1.9"
end
