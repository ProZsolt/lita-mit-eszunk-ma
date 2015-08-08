require 'net/http'
require 'uri'
require 'json'
require 'time'

module Lita
  module Handlers
    class MitEszunkMa < Handler
    end

    Lita.register_handler(MitEszunkMa)
  end
end
