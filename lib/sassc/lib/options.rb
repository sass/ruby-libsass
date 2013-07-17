module SassC::Lib
  class Options < FFI::Struct
    layout :output_style,    :int32,
           :source_comments, :int32,
           :include_paths,   :pointer,
           :image_path,      :pointer,
           :takana_path,     :pointer

  end

end