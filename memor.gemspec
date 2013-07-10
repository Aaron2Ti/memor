# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'memor/version'

Gem::Specification.new do |s|
  s.name        = 'memor'
  s.version     = Memor::VERSION
  s.authors     = ['Aaron Tian']
  s.email       = ['Aaron2Ti@gmail.com']
  s.homepage    = 'https://rubygems.org/gems/memor'
  s.summary     = %q{simple memoize function without alias method chain}
  s.description = %q{memoize function without alias method chain}

  s.rubyforge_project = 'memor'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  # s.add_runtime_dependency 'rest-client'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'debugger'
end
