require "spec_helper"

describe SassC::Lib do
  it "should create a context" do
    ptr = SassC::Lib.sass_new_context
    SassC::Lib.sass_free_context(ptr)
  end

  it "should should compile some scss with ffi api" do
    context = SassC::Lib::Context.new(SassC::Lib.sass_new_context)
    options = SassC::Lib::SassOptions.new

    options[:output_style] = 0
    options[:source_comments] = 0
    options[:image_path] = FFI::MemoryPointer.from_string("")
    options[:include_paths] = FFI::MemoryPointer.from_string("")

    context[:options] = options
    context[:source_string] = FFI::MemoryPointer.from_string %{
      .hello { color: blue; }
    }

    SassC::Lib.sass_compile(context)

    context[:output_string].should eq ".hello {\n  color: blue; }\n"
    SassC::Lib.sass_free_context(context)
  end
end

