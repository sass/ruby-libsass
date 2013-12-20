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

    def from_ruby(val)
      self[:tag] = :SASS_BOOLEAN
      self[:value] = val ? 1 : 0
      self
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

    def from_ruby(val)
      self[:tag] = :SASS_NUMBER
      self[:value] = val
      # TODO: unit
      self[:unit] = FFI::MemoryPointer.from_string("")
      self
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

    def from_ruby(val)
      self[:tag] = :SASS_COLOR
      self[:r] = val.r
      self[:g] = val.g
      self[:b] = val.b
      self[:a] = val.a
      self
    end
  end

  class SassString < FFI::Struct
    # struct Sass_String {
    #   enum Sass_Tag tag;
    #   char*         value;
    # };
    layout :tag, SassTag,
      :value, :pointer

    def from_ruby(val)
      self[:tag] = :SASS_STRING
      self[:value] = FFI::MemoryPointer.from_string(val)
      self
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

    def from_ruby(val)
      num_values = val.count

      self[:tag] = :SASS_LIST
      self[:length] = num_values
      self[:separator] = :SASS_SPACE

      values_ptr = FFI::MemoryPointer.new(SassValue, num_values)

      num_values.times do |i|
        SassValue.new(values_ptr + i * SassValue.size).from_ruby(val[i])
      end

      self[:values] = values_ptr

      self
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

    def from_ruby(val)
      self[:tag] = :SASS_NULL
      self
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

    def from_ruby(val)
      type_name = case val
      when String
        :string
      when NilClass
        :null
      when Array
        :list
      when TrueClass, FalseClass
        :boolean
      when Numeric
        :number
      when SassC::Engine::Color
        :color
      else
        raise "Don't know how to convert #{val.inspect} to sass value"
      end

      self[type_name].from_ruby(val)
      self
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
