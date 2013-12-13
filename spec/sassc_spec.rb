require "spec_helper"

describe SassC::Lib do
  it "should create a context" do
    context = SassC::Lib.sass_new_context
    SassC::Lib.sass_free_context(context)
  end
end

