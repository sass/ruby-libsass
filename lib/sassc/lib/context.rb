module SassC::Lib
  class Context < FFI::Struct
    layout :input_string,  :pointer,
           :output_string, :string,
           :sass_options,  :pointer,
           :error_status,  :int32,
           :error_message, :string
  end
end