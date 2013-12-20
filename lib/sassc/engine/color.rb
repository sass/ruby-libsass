require 'ostruct'

module SassC
  class Engine::Color < OpenStruct
    def initialize(r=0, g=0, b=0, a=255)
      super()
      self.r = r
      self.g = g
      self.b = b
      self.a = a
    end
  end
end
