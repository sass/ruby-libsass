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

    def set_custom_functions(input_funcs)
      num_funcs = input_funcs.count + 1
      funcs_ptr = FFI::MemoryPointer.new(SassC::Lib::SassCFunctionDescriptor, num_funcs)

      num_funcs.times.map do |i|
        fn = SassC::Lib::SassCFunctionDescriptor.new(funcs_ptr + i * SassC::Lib::SassCFunctionDescriptor.size)

        if input = input_funcs[i]
          signature, block = input
          fn[:signature] = FFI::MemoryPointer.from_string(signature)
          fn[:function] = FFI::Function.new(SassC::Lib::SassValue.by_value, [SassC::Lib::SassValue.by_value]) do |arg|
            SassC::Lib::SassValue.from_ruby block.call arg.to_ruby
          end
        end

        fn
      end

      self[:c_functions] = funcs_ptr
    end

    def free
      SassC::Lib.sass_free_context(self)
    end
  end
end