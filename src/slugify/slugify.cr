require "cadmium_transliterator"

module Geera
  class Slugify
    def slugify(value : String) : String
      Cadmium::Transliterator.parameterize(value)
    end
  end
end
