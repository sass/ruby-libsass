require_relative 'lib'
require_relative 'error'

module SassC
  class Engine
    def initialize(input, options = {})
      @input = input
      @options = options
      @custom_functions = []
    end

    def custom_function(signature, &block)
      @custom_functions << [signature, block]
    end

    def render
      ctx = SassC::Lib::Context.create(@input, @options)

      unless @custom_functions.empty?
        ctx.set_custom_functions @custom_functions
      end

      SassC::Lib.sass_compile(ctx)

      if ctx[:error_status] != 0
        raise SyntaxError.new("Sass error #{ctx[:error_message]}")
      end

      ctx[:output_string]
    ensure
      ctx && ctx.free
    end
  end
end

require "sassc/engine/color"
require "sassc/engine/list"
require "sassc/engine/number"
