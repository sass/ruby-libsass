module SassC
  class Engine::List < Array
    SEPARATORS = [" ", ","]
    DEFAULT_SEPARATOR = :" "

    def initialize(arr, sep=nil)
      super(arr)
      self.separator = sep if sep
    end

    def separator
      @separator || DEFAULT_SEPARATOR
    end

    def separator=(sep)
      unless SEPARATORS.include? sep.to_s
        raise "delimiter must be one of ` `, `,`"
      end

      @separator = sep.to_sym
    end
  end
end
