
require 'sassc/lib'

module SassC
  class Engine
    def initialize(input, options = {})
      @input = input
      @options = options
    end
    
    def render
      ctx = SassC::Lib::Context.create(@input, @options)
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