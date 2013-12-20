module SassC::Lib
  SassTag = enum(
    :SASS_BOOLEAN,
    :SASS_NUMBER,
    :SASS_COLOR,
    :SASS_STRING,
    :SASS_LIST,
    :SASS_NULL,
    :SASS_ERROR
  )

  SassSeparator = enum(
    :SASS_COMMA,
    :SASS_SPACE
  )

  class SassUnknown < FFI::Struct
    # struct Sass_Unknown {
    #   enum Sass_Tag tag;
    # };
    layout :tag, SassTag
  end

  class SassBoolean < FFI::Struct
    # struct Sass_Boolean {
    #   enum Sass_Tag tag;
    #   int           value;
    # };
    layout :tag, SassTag,
      :value, :int

    def self.from_ruby(val)
      ret_val = SassC::Lib::SassValue.new()
      ret_val[:boolean][:tag] = :SASS_BOOLEAN
      ret_val[:boolean][:value] = val ? 1 : 0
      ret_val
    end

    def to_ruby
      self[:boolean][:value] == 1
    end
  end

  class SassNumber < FFI::Struct
    # struct Sass_Number {
    #   enum Sass_Tag tag;
    #   double        value;
    #   char*         unit;
    # };
    layout :tag, SassTag,
      :value, :double,
      :unit, :pointer

    def self.from_ruby(val)
      ret_val = SassC::Lib::SassValue.new()
      ret_val[:number][:tag] = :SASS_NUMBER
      ret_val[:number][:value] = val
      # TODO: unit
      ret_val[:number][:unit] = FFI::MemoryPointer.from_string("")
      ret_val
    end
  end

  class SassColor < FFI::Struct
    # struct Sass_Color {
    #   enum Sass_Tag tag;
    #   double        r;
    #   double        g;
    #   double        b;
    #   double        a;
    # };
    layout :tag, SassTag,
      :r, :double,
      :g, :double,
      :b, :double,
      :a, :double

    def self.from_ruby(val)
      ret_val = SassC::Lib::SassValue.new()
      ret_val[:color][:tag] = :SASS_COLOR
      ret_val[:color][:r] = val.r
      ret_val[:color][:g] = val.g
      ret_val[:color][:b] = val.b
      ret_val[:color][:a] = val.a
      ret_val

    end
  end

  class SassString < FFI::Struct
    # struct Sass_String {
    #   enum Sass_Tag tag;
    #   char*         value;
    # };
    layout :tag, SassTag,
      :value, :pointer

    def self.from_ruby(val)
      ret_val = SassC::Lib::SassValue.new()
      ret_val[:string][:tag] = :SASS_STRING
      ret_val[:string][:value] = FFI::MemoryPointer.from_string(val)
      ret_val
    end

    def to_ruby
      self[:value].read_string
    end
  end

  class SassList < FFI::Struct
    # struct Sass_List {
    #   enum Sass_Tag       tag;
    #   enum Sass_Separator separator;
    #   size_t              length;
    #   union Sass_Value*   values;
    # };
    layout :tag, SassTag,
      :separator, SassSeparator,
      :length, :size_t,
      :values, :pointer

    def self.from_ruby(val)
      num_values = val.count

      ret_val = SassC::Lib::SassValue.new()
      ret_val[:list][:tag] = :SASS_LIST
      ret_val[:list][:length] = num_values
      ret_val[:list][:separator] = :SASS_SPACE

      values_ptr = FFI::MemoryPointer.new(SassValue, num_values)
      # num_values.times do |i|
      #   SassValue.new(values_ptr + i).from_ruby(val[i])
      #   SassValue.from_ruby(val[i], dest)
      # end

      ret_val
    end

    def to_ruby
      values_ptr = self[:values]
      self[:length].times.map do |i|
        SassValue.new(values_ptr + i).to_ruby
      end
    end
  end

  class SassNull < FFI::Struct
    # struct Sass_Null {
    #   enum Sass_Tag tag;
    # };
    layout :tag, SassTag

    def self.from_ruby()
      ret_val = SassC::Lib::SassValue.new()
      ret_val[:null][:tag] = :SASS_NULL
      ret_val
    end

    def to_ruby()
    end
  end

  class SassError < FFI::Struct
    # struct Sass_Error {
    #   enum Sass_Tag tag;
    #   char*         message;
    # };
    layout :tag, SassTag,
      :message, :string
  end

  class SassValue < FFI::Union
    # // represention of Sass values in C
    # union Sass_Value {
    #   struct Sass_Unknown unknown;
    #   struct Sass_Boolean boolean;
    #   struct Sass_Number  number;
    #   struct Sass_Color   color;
    #   struct Sass_String  string;
    #   struct Sass_List    list;
    #   struct Sass_Null    null;
    #   struct Sass_Error   error;
    # };
    layout :unknown, SassUnknown,
      :boolean, SassBoolean,
      :number, SassNumber,
      :color, SassColor,
      :string, SassString,
      :list, SassList,
      :null, SassNull,
      :error, SassError

    def self.from_ruby(val)
      case val
      when String
        SassString.from_ruby(val)
      when NilClass
        SassNull.from_ruby()
      when Array
        SassList.from_ruby(val)
      when TrueClass, FalseClass
        SassBoolean.from_ruby(val)
      when Numeric
        SassNumber.from_ruby(val)
      when SassC::Engine::Color
        SassColor.from_ruby(val)
      else
        raise "Don't know how to convert #{val.inspect} to sass value"
      end
    end

    def to_ruby
      case self[:unknown][:tag]
      when :SASS_LIST
        self[:list].to_ruby
      when :SASS_STRING
        self[:string].to_ruby
      else
        raise "don't know how to convert #{self[:unknown][:tag]} to ruby"
      end
    end
  end
end
