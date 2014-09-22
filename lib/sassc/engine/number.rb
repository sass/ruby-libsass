require 'delegate'

module SassC
  class Engine::Number < SimpleDelegator
    attr_accessor :unit

    def initialize(num, unit="")
      super(num)
      @unit = unit
    end
  end
end
