# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trace_visualization/version'

Gem::Specification.new do |spec|
  spec.name          = 'trace_visualization'
  spec.version       = TraceVisualization::VERSION
  spec.authors       = ['Sergey']
  spec.email         = ['mastedm@gmail.com']
  spec.description   = %q{
    Intelligent visualization of software traces    
  }
  spec.summary       = %q{
    Software for smart trace visualization  
  }
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  
  spec.add_development_dependency 'redcarpet', '~> 1.17'
  spec.add_development_dependency 'yard', '~> 0.7.5'
  
  spec.add_development_dependency 'rspec-core', '~> 2.0'
  spec.add_development_dependency 'rspec-expectations', '~> 2.0'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'rr', '~> 1.0'
end
