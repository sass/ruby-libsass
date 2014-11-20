require 'sassc'

if defined? ::Sass
  if ::Sass == ::SassC
    warn 'warning: Sass already defined. Possible double load issue.'
  else
    raise LoadError.new('Sass already defined. Refusing to clobber.')
  end
end

::Sass = ::SassC
$LOAD_PATH.unshift File.expand_path('../sass_shim', __FILE__)
