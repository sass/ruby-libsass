require_relative 'options'

module SassC::Lib
  class Context < FFI::Struct
    STYLES = %w(nested expanded compact compressed)
    SOURCE_COMMENTS = %w(none default map)

    layout :source_string,    :pointer,
           :output_string,    :string,
           :options,          Options,
           :error_status,     :int32,
           :error_message,    :string

    def self.create(input_string, options = {})
      ptr = SassC::Lib.sass_new_context()
      ctx = SassC::Lib::Context.new(ptr)

      ctx[:source_string] = FFI::MemoryPointer.from_string(input_string || "")
     
      ctx[:options][:output_style]     = STYLES.index(options[:output_style] || "nested")
      ctx[:options][:source_comments]  = SOURCE_COMMENTS.index(options[:source_comments] || "none")

      ctx[:options][:include_paths]    = FFI::MemoryPointer.from_string(options[:include_paths] || "")
      ctx[:options][:image_path]       = FFI::MemoryPointer.from_string(options[:image_path] || "")

      ctx[:options][:takana_path]       = FFI::MemoryPointer.from_string(options[:takana_path] || "")
      
      ctx
    end
  end
end