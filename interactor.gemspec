# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'interactor'
  spec.version = '1.0.0'
  spec.summary = 'Dry::Validation-based interactor'
  spec.authors = ['Vladimir Kleshko']

  spec.files = %w[
    lib/interactor.rb
    lib/interactor/base.rb
    lib/interactor/validator.rb
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency 'dry-validation', '~> 1.6.0'
  spec.add_dependency 'rails', '~> 6.0'
end
