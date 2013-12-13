require 'ffi'

require 'sassc/lib/context'

module SassC
  # Represents the exact wrapper around libsass
  module Lib
    extend FFI::Library
    ffi_lib "sass"
    attach_function :sass_new_context, [], :pointer
    attach_function :sass_new_file_context, [], :pointer
    attach_function :sass_new_folder_context, [], :pointer
    
    attach_function :sass_free_context, [:pointer], :void
    attach_function :sass_free_file_context, [:pointer], :void
    attach_function :sass_free_folder_context, [:pointer], :void
    
    attach_function :sass_compile, [:pointer], :int32
    attach_function :sass_compile_file, [:pointer], :int32
  end
end