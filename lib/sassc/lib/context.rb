require 'sassc/lib/sass_options'

module SassC::Lib
  class Context < FFI::Struct
    # struct sass_context {
    #   const char* source_string;
    #   char* output_string;
    #   struct sass_options options;
    #   int error_status;
    #   char* error_message;
    #   struct Sass_C_Function_Data* c_functions;
    #   char** included_files;
    #   int num_included_files;
    # };
    layout :source_string, :pointer,
      :output_string, :string,
      :options, SassOptions,
      :error_status, :int,
      :error_message, :string,
      :c_functions, :pointer,
      :included_files, :pointer,
      :num_included_files, :int

    def self.create(input_string, options = {})
      ptr = SassC::Lib.sass_new_context()
      ctx = SassC::Lib::Context.new(ptr)
      ctx[:source_string] = FFI::MemoryPointer.from_string(input_string || "")
      ctx[:options] = SassOptions.create(options)
      ctx
    end

    def free
      SassC::Lib.sass_free_context(self)
    end
  end
end