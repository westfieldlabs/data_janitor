# coding: utf-8
require_relative 'lib/data_janitor/version'

Gem::Specification.new do |spec|
  spec.name          = 'data_janitor'
  spec.version       = DataJanitor::VERSION
  spec.authors       = ['Louis Tran', 'Zhenya Mirkin']
  spec.email         = ['tran.louis@gmail.com']

  spec.summary       = %q{Rake task to check validity of column types and values.}
  spec.description   = %q{Rake task to check validity of column types and values.}
  spec.homepage      = 'https://github.com/westfieldlabs/data_janitor'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_dependency 'rails', '~> 4.2'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
end
