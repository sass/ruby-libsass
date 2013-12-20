module SassC
  class Engine::Color
    attr_accessor :r, :g, :b, :a
    
    def initialize(r=0, g=0, b=0, a=255)
      @r = r
      @g = g
      @b = b
      @a = a
    end
  end
end
