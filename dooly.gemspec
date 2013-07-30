$:.push File.expand_path("../lib", __FILE__)
require 'dooly/version'

Gem::Specification.new do |s|
  s.name = 'dooly'
  s.description = 'Some helpful feature for rails'
  s.version = Dooly::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = '2013-07-23'
  s.summary = 'Little dinosaur, Dooly'
  s.homepage = 'http://github.com/insoul/dooly'
  s.authors = ['insoul']
  s.email = 'ensoul@empal.com'
  
  s.files = Dir['**/*'].select{|f| File.file?(f)}
  s.require_path = %w{lib}
  
  s.add_dependency 'rake'
  s.add_dependency 'activemodel'
  s.add_dependency 'activesupport'
  
  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-remote'
  s.add_development_dependency 'pry-stack_explorer'
  s.add_development_dependency 'pry-debugger'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'shoulda-context'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-test'
end