module SassC::Lib
  class SassCFunctionDescriptor < FFI::Struct
    # struct Sass_C_Function_Descriptor {
    #   const char*     signature;
    #   Sass_C_Function function;
    # };
    layout :signature, :pointer,
      :function, :pointer
  end
end
