# frozen_string_literal: true

require_relative 'nuhttp/app'
require_relative 'nuhttp/builder'
require_relative 'nuhttp/context'
require_relative 'nuhttp/router'
require_relative 'nuhttp/version'

module NuHttp
  class Error < StandardError; end

  # @rbs &block: (Builder) -> void
  def self.app(&block)
    return App.new(Router.new) if block == nil
    builder = Builder.new
    block.call(builder)
    builder.build
  end
end
