require 'jsbin-client/config'
require 'ostruct'

class JsBinClient
  attr_reader :options

  def initialize(options = {})
    @options = OpenStruct.new(Config.to_hash.merge(options || {}))
  end
end