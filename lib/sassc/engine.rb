
require 'sassc/lib'

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

      success = SassC::Lib.sass_compile(ctx)

      unless ctx[:error_status] == 0
        raise ctx[:error_message]
      end

      ctx[:output_string]
    ensure
      ctx && ctx.free
    end
  end
end

require "sassc/engine/color"
