# frozen_string_literal: true
# rbs_inline: enabled

require 'herb'

module NuHttp
  class HerbRenderer
    def render(template_path, locals = {})
      template_src = File.read(template_path)
      engine = Herb::Engine.new(template_src, filename: template_path)

      erbctx = EmptyBinding.get_binding
      locals.each do |name, value|
        erbctx.local_variable_set(name, value)
      end

      # Herb::Engine generates Ruby code that returns the rendered string when evaluated
      ruby_src = engine.src
      eval(ruby_src, erbctx)
    end
  end

  class EmptyBinding
    def self.get_binding #: Binding
      binding
    end
  end
end
