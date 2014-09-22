require "spec_helper"

describe SassC::Lib do
  it "should create a context" do
    ptr = SassC::Lib.sass_new_context
    SassC::Lib.sass_free_context(ptr)
  end

  it "should should compile scss with ffi api" do
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

  it "should should register custom function" do
    context = SassC::Lib::Context.new(SassC::Lib.sass_new_context)
    options = SassC::Lib::SassOptions.new

    options[:output_style] = 0
    options[:source_comments] = 0
    options[:image_path] = FFI::MemoryPointer.from_string("")
    options[:include_paths] = FFI::MemoryPointer.from_string("")

    # Create a list of functions
    num_funcs = 3
    funcs_ptr = FFI::MemoryPointer.new(SassC::Lib::SassCFunctionDescriptor, num_funcs)
    funcs = num_funcs.times.collect do |i|
      SassC::Lib::SassCFunctionDescriptor.new(funcs_ptr + i * SassC::Lib::SassCFunctionDescriptor.size)
    end

    funcs[0][:signature] = FFI::MemoryPointer.from_string("custom_func()")
    funcs[0][:function] = FFI::Function.new(SassC::Lib::SassValue.by_value, [SassC::Lib::SassValue.by_value]) do |val|
      ret_value = SassC::Lib::SassValue.new()
      ret_value[:string][:tag] = :SASS_STRING
      ret_value[:string][:value] = FFI::MemoryPointer.from_string("hello world :)")

      ret_value
    end

    funcs[1][:signature] = FFI::MemoryPointer.from_string("custom_func2($arg)")
    funcs[1][:function] = FFI::Function.new(SassC::Lib::SassValue.by_value, [SassC::Lib::SassValue.by_value]) do |val|
      arg_value = case val[:unknown][:tag]
      when :SASS_LIST
        list = val[:list]
        len = list[:length]
        first_arg = SassC::Lib::SassValue.new(list[:values])
        case first_arg[:unknown][:tag]
        when :SASS_STRING
          first_arg[:string][:value].read_string
        else
          raise "unknown type"
        end
      else
        raise "unknown argument type"
      end

      ret_value = SassC::Lib::SassValue.new()
      ret_value[:string][:tag] = :SASS_STRING
      ret_value[:string][:value] = FFI::MemoryPointer.from_string("<<#{arg_value}>>")
      ret_value
    end

    funcs[2][:signature] = 0
    funcs[2][:function] = 0

    context[:c_functions] = funcs_ptr

    context[:options] = options
    context[:source_string] = FFI::MemoryPointer.from_string %{
      .hello { color: custom_func(); }
      .world { color: custom_func2("hello world"); }
    }

    SassC::Lib.sass_compile(context)

    context[:output_string].should eq ".hello {\n  color: hello world :); }\n\n.world {\n  color: <<\"hello world\">>; }\n"
    SassC::Lib.sass_free_context(context)

  end
end

describe SassC::Engine do
  it "should compile scss" do
    engine = SassC::Engine.new(".hello { color: blue; }")
    engine.render.should eq ".hello {\n  color: blue; }\n"
  end

  it "should set a custom function" do
    engine = SassC::Engine.new(".hello { color: hello(yeah); }")

    engine.custom_function "hello($arg)" do |arg|
      "meets and greets"
    end

    engine.render.should eq ".hello {\n  color: meets and greets; }\n"
  end


  it "should get error message" do
    engine = SassC::Engine.new(".hello { color: blue;")
    expect do
      engine.render
    end.to raise_error
  end

  describe "converting ruby types to sass types" do
    before :each do
      @engine = SassC::Engine.new(".hello { result: test-func(); }")
    end

    it "should convert string" do
      @engine.custom_function "test-func()" do
        "hello"
      end

      @engine.render.should eq ".hello {\n  result: hello; }\n"
    end

    it "should convert nil" do
      @engine.custom_function "test-func()" do
        nil
      end

      @engine.render.should eq ".hello {\n  result: null; }\n"
    end

    it "should convert boolean" do
      @engine.custom_function "test-func()" do
        true
      end

      @engine.render.should eq ".hello {\n  result: true; }\n"
    end

    it "should convert number" do
      @engine.custom_function "test-func()" do
        123
      end

      @engine.render.should eq ".hello {\n  result: 123; }\n"
    end

    it "should convert number with unit" do
      @engine.custom_function "test-func()" do
        SassC::Engine::Number.new 123, "px"
      end

      @engine.render.should eq ".hello {\n  result: 123px; }\n"
    end

    it "should convert color" do
      @engine.custom_function "test-func()" do
        SassC::Engine::Color.new(255, 128, 64)
      end

      @engine.render.should eq ".hello {\n  result: #ff8040; }\n"
    end

    it "should convert array" do
      @engine.custom_function "test-func()" do
        [1,2, "hello", false]
      end

      @engine.render.should eq ".hello {\n  result: 1 2 hello false; }\n"
    end

    it "should convert list" do
      @engine.custom_function "test-func()" do
        SassC::Engine::List.new([1,2, "hello", false], ",")
      end

      @engine.render.should eq ".hello {\n  result: 1, 2, hello, false; }\n"
    end
  end

  describe "converting sass types to ruby types" do
    it "should convert string" do
      engine = SassC::Engine.new(".hello { result: test-func('hi'); }")
      engine.custom_function "test-func($arg)" do |arg|
        arg.should eq ["'hi'"]
      end
      engine.render
    end

    it "should convert number" do
      engine = SassC::Engine.new(".hello { result: test-func(20); }")
      engine.custom_function "test-func($arg)" do |arg|
        arg.should eq [20]
        arg.first.unit.should eq ""
      end
      engine.render
    end

    it "should convert number with unit" do
      engine = SassC::Engine.new(".hello { result: test-func(99px); }")
      engine.custom_function "test-func($arg)" do |arg|
        arg.should eq [99]
        arg.first.unit.should eq "px"
      end
      engine.render
    end

    it "should convert boolean" do
      engine = SassC::Engine.new(".hello { result: test-func(true); }")
      engine.custom_function "test-func($arg)" do |arg|
        arg.should eq [true]
      end
      engine.render
    end

    it "should convert color" do
      engine = SassC::Engine.new(".hello { result: test-func(#dadfed); }")
      engine.custom_function "test-func($arg)" do |arg|
        arg.should eq [SassC::Engine::Color.new(218, 223, 237, 1)]
      end
      engine.render
    end

    it "should convert null" do
      engine = SassC::Engine.new(".hello { result: test-func(null); }")
      engine.custom_function "test-func($arg)" do |arg|
        arg.should eq [nil]
      end
      engine.render
    end

    it "should convert null" do
      engine = SassC::Engine.new(".hello { result: test-func(null); }")
      engine.custom_function "test-func($arg)" do |arg|
        arg.should eq [nil]
      end
      engine.render
    end

    it "should convert list" do
      engine = SassC::Engine.new(".hello { result: test-func(1,2,(a b c)); }")
      engine.custom_function "test-func($arg1, $arg2, $arg3)" do |arg|
        arg.should eq [1, 2, ["a", "b", "c"]]
        arg.separator.should eq :","
        arg[2].separator.should eq :" "
      end
      engine.render
    end
  end
end

