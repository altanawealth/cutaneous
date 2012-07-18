
module Cutaneous
  # Manages a set of Loaders that render templates
  class Engine
    attr_accessor :loader_class, :default_format

    def initialize(template_roots, lexer_class, default_format = "html")
      @roots          = Array(template_roots)
      @lexer_class    = lexer_class
      @loader_class   = FileLoader
      @default_format = default_format
      @loaders        = {}
    end

    def render_file(path, context, format = default_format)
      file_loader(format).render(path, context)
    end

    alias_method :render, :render_file

    def render_string(template_string, context, format = default_format)
      string_loader(format).render(template_string, context)
    end

    # Create and cache a file loader on a per-format basis
    def file_loader(format)
      @loaders[format.to_s] ||= loader_class.new(@roots, format).tap do |loader|
        loader.lexer_class = @lexer_class
      end
    end

    # Not worth caching string templates as they are most likely to be one-off
    # instances & not repeated in the lifetime of the engine.
    def string_loader(format)
      StringLoader.new(file_loader(format))
    end
  end

  class CachingEngine < Engine
    def initialize(template_roots, lexer_class, default_format = "html")
      super
      @loader_class = CachedFileLoader
    end
  end
end
