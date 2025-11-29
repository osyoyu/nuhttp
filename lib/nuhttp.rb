# frozen_string_literal: true
# rbs_inline: enabled

require_relative 'nuhttp/app'
require_relative 'nuhttp/builder'
require_relative 'nuhttp/context'
require_relative 'nuhttp/router'
require_relative 'nuhttp/version'

module NuHttp
  class Error < StandardError; end

  # Entrypoint to define a NuHttp app.
  # If a block is given, a NuHttp::Builder is yielded.
  # If not, a bare builder will be returned.
  # @rbs &block: (Builder) -> void
  def self.app(&block)
    builder = Builder.new
    return builder if block == nil
    block.call(builder)
    builder.build
  end
end
