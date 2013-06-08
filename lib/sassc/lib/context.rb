require_relative 'sass_options'

module SassC::Lib
  class Context < FFI::Struct
    # struct sass_context {
    #   const char* source_string;
    #   char* output_string;
    #   struct sass_options options;
    #   int error_status;
    #   char* error_message;
    #   struct Sass_C_Function_Data* c_functions;
    # };
    layout :source_string,  :pointer,
           :output_string, :string,
           :sass_options,  SassOptions.ptr,
           :error_status,  :int32,
           :error_message, :string

    def self.create(input_string, options = {})
      ptr = SassC::Lib.sass_new_context()
      ctx = SassC::Lib::Context.new(ptr)
      ctx[:source_string] = SassC::Lib.to_char(input_string || "")
      
      # TODO: Disabled the options. For some reason doing this line breaks everything!
      # ctx[:sass_options] = SassOptions.create(options)
      return ctx
    end
  end
end