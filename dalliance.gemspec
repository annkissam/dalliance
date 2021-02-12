# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dalliance/version"

Gem::Specification.new do |s|
  s.name        = "dalliance"
  s.version     = Dalliance::VERSION::STRING
  s.authors     = ["Eric Sullivan"]
  s.email       = ["eric.sullivan@annkissam.com"]
  s.homepage    = "https://github.com/annkissam/dalliance"
  s.summary     = %q{ Wrapper for an ActiveRecord model with a single ascynhronous method }
  s.description = %q{ Background processing for ActiveRecord using a 'delayable' worker and a state_machine }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rails', '>= 5.0', "< 6.2")

  s.add_dependency('state_machine')

  s.add_development_dependency('rspec', '>= 3.0.0')
  s.add_development_dependency('delayed_job', '>= 3.0.0')
  s.add_development_dependency('delayed_job_active_record')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('resque')
  s.add_development_dependency('bundler-audit')
  s.add_development_dependency('rubocop', '~> 0.78')
  s.add_development_dependency('rspec_junit_formatter')
end
