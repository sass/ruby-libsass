require 'ffi'

require_relative 'lib/context'

module SassC
  # Represents the exact wrapper around libsass
  module Lib
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), '../libsass.bundle')
    attach_function :sass_new_context, [], :pointer
    attach_function :sass_compile, [:pointer], :int32
    
    def self.to_char(string)
      # get the number of bytes in the key
      bytecount = string.unpack("C*").size

      # create a pointer to memory and write the file to it
      ptr = FFI::MemoryPointer.new(:char, bytecount)
      ptr.put_bytes(0, string, 0, bytecount)
    end
  end
end