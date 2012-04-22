
require_relative 'lib'

module SassC
  class Engine
    def initialize(input, options = {})
      @input = input
    end
    
    def render
      ptr = SassC::Lib.sass_new_context()
      ctx = SassC::Lib::Context.new(ptr)
      ctx[:input_string] = SassC::Lib.to_char(@input)
      SassC::Lib.sass_compile(ctx)
      ctx[:output_string]
    end
  end
end