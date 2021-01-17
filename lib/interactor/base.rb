# frozen_string_literal: true

module Interactor
  class Base
    SUCCESS_RESPONSE = ::OpenStruct.new(success?: true)

    class Result
      attr_reader :value, :error

      def initialize(value = nil, error = nil)
        @value = value
        @error = error
      end

      def success?
        @error.nil?
      end

      def failure?
        @error.present?
      end
    end

    class Failure < ::RuntimeError
      attr_reader :code, :message

      def initialize(code, message)
        @code = code
        @message = message
        super()
      end
    end

    attr_reader :args

    def initialize(arguments)
      @args = ::OpenStruct.new(arguments)
    end

    def fail!(code = 'UNKNOWN_ERROR', message = '')
      logger.error(code.to_s) if message.empty?
      logger.error("#{code} (#{message})") if message.present?
      raise ::Interactor::Base::Failure.new(code, message)
    end

    def logger
      ::Rails.logger
    end

    def cached(key, expires_in = 5.minutes, &block)
      ::Rails.cache.fetch(key, expires_in: expires_in, &block)
    end

    def self.perform(arguments = {})
      run(arguments, false)
    end

    def self.perform!(arguments = {})
      run(arguments, true).value
    end

    def self.prettify(errors)
      errors.map { |e| "#{e.path} #{e.text}" }.join(', ')
    end

    def self.run(arguments, unwrapped)
      arguments = arguments.to_h.symbolize_keys

      start = ::Time.now.to_f
      instance = new(arguments)

      instance.logger.debug("#{self.name} started")

      begin
        instance.validate!
        result = ::Interactor::Base::Result.new(instance.perform)
      rescue ::ApplicationInteractor::Failure => e
        result = ::Interactor::Base::Result.new(nil, e.code)
        raise e if unwrapped
      end

      total = (::Time.now.to_f - start) * 1000
      instance.logger.debug("#{self.name} finished in #{total.round(2)} ms")

      result
    end

    def self.expects(&block)
      @expects ||= (block.present? ? ::Dry::Validation::Contract(&block) : nil)
    end

    def validate!
      return if self.class.expects.nil?

      result = self.class.expects.call(args.to_h)
      if result.success?
        @args = ::OpenStruct.new(result.to_h)
      else
        fail!('INVALID_ARGUMENTS', self.class.prettify(result.errors))
      end
    end
  end
end
