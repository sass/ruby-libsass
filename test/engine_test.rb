require 'test/unit'
require_relative "../lib/sassc.rb"

class TestEngine < Test::Unit::TestCase
  def test_null_case
    assert_equal "", SassC::Engine.new(nil).render 
  end

  def test_empty_case
    assert_equal "", SassC::Engine.new("").render
  end

  def test_base_case
    assert_equal "body {\n  color: red; }\n", 
                 SassC::Engine.new("$var: red; body { color: $var; }").render
  end

  def test_error_case
    assert_raise SassC::SyntaxError do
      SassC::Engine.new("body { color: $undefined; }").render
    end
  end

  def test_options
    assert_equal  "body {\n  background: red; }\n".force_encoding(Encoding::ASCII_8BIT),
                  SassC::Engine.new('@import "test/test.scss";', { 
                    include_paths: Dir.pwd, 
                    image_path: Dir.pwd 
                  }).render
    
  end
end