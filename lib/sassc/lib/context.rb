require_relative 'sass_options'

module SassC::Lib
  class Context < FFI::Struct
    layout :input_string,  :pointer,
           :output_string, :string,
           :sass_options,  SassOptions.ptr,
           :error_status,  :int32,
           :error_message, :string

    def self.create(input_string, options = {})
      ptr = SassC::Lib.sass_new_context()
      ctx = SassC::Lib::Context.new(ptr)
      ctx[:input_string] = SassC::Lib.to_char(input_string || "")
      ctx[:sass_options] = SassOptions.create(options)
      return ctx
    end
  end
end