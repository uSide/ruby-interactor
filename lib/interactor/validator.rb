# frozen_string_literal: true

require 'dry-types'

module Interactor
  class Validator < ::Dry::Validation::Contract
    module Types
      include ::Dry.Types()
    end
  end
end
