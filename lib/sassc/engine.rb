
require_relative 'lib'

module SassC
  class Engine
    def initialize(input, options = {})
      @input = input
      @options = options
    end
    
    def render
      ctx = SassC::Lib::Context.create(@input, @options)
      #puts ctx[:sass_options][:output_style]
      SassC::Lib.sass_compile(ctx)
      ctx[:output_string]
    end
  end
end