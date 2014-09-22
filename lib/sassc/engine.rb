require_relative 'lib'
require_relative 'error'

module SassC
  class Engine
    def initialize(input, options = {})
      @input = input
      @options = options
    end
    
    def render
      ctx = SassC::Lib::Context.create(@input, @options)

      SassC::Lib.sass_compile(ctx)

      if ctx[:error_status] != 0
        raise SyntaxError.new("Sass error #{ctx[:error_message]}")
      end

      ctx[:output_string]
    end
  end
end