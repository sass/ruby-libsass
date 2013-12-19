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
  end

  class SassNumber < FFI::Struct
    # struct Sass_Number {
    #   enum Sass_Tag tag;
    #   double        value;
    #   char*         unit;
    # };
    layout :tag, SassTag,
      :value, :double,
      :unit, :string
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
  end

  class SassString < FFI::Struct
    # struct Sass_String {
    #   enum Sass_Tag tag;
    #   char*         value;
    # };
    layout :tag, SassTag,
      :value, :pointer
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
  end

  class SassNull < FFI::Struct
    # struct Sass_Null {
    #   enum Sass_Tag tag;
    # };
    layout :tag, SassTag
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
  end
end
