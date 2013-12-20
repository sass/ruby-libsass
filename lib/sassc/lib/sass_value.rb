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

  TAG_TO_FIELD = {
    :SASS_BOOLEAN => :boolean,
    :SASS_NUMBER => :number,
    :SASS_COLOR => :color,
    :SASS_STRING => :string,
    :SASS_LIST => :list,
    :SASS_NULL => :null,
    :SASS_ERROR => :error
  }

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
      self[:value] == 1
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
      unit = if val.respond_to? :unit
        val.unit
      else
        ""
      end

      self[:unit] = FFI::MemoryPointer.from_string(unit)
      self
    end

    def to_ruby
      SassC::Engine::Number.new self[:value], self[:unit].read_string
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

    def to_ruby
      SassC::Engine::Color.new(self[:r], self[:g], self[:b], self[:a])
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

      self[:separator] = if val.respond_to?(:separator)
        case val.separator
        when :" "
         :SASS_SPACE
        when :","
         :SASS_COMMA
        else
          raise "Unknown separator"
        end
      else
        :SASS_SPACE
      end

      values_ptr = FFI::MemoryPointer.new(SassValue, num_values)

      num_values.times do |i|
        SassValue.new(values_ptr + i * SassValue.size).from_ruby(val[i])
      end

      self[:values] = values_ptr

      self
    end

    def to_ruby
      values_ptr = self[:values]
      arr = self[:length].times.map do |i|
        SassValue.new(values_ptr + i * SassValue.size).to_ruby
      end

      sep = case self[:separator]
      when :SASS_SPACE
        :" "
      when :SASS_COMMA
        :","
      end

      SassC::Engine::List.new arr, sep
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
      when Numeric, SassC::Engine::Number
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
      field = TAG_TO_FIELD[self[:unknown][:tag]]
      unless field
        raise "don't know how to convert #{self[:unknown][:tag]} to ruby"
      end

      self[field].to_ruby
    end
  end
end
