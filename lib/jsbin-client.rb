require 'jsbin-client/config'
require 'jsbin-client/exceptions'
require 'jsbin-client/rest'
require 'ostruct'
require 'rest-client'

class JsBinClient
  API_PREFIX = 'api/'
  attr_reader :options

  def initialize(options_param = {})
    @options = OpenStruct.new(Config.to_hash.merge(options_param || {}))
    @rest = Rest.new(@options)
  end

  # retrieve a bin
  def get(id, revision = nil)
    url = [id, revision].compact.join('/')
    @rest.get(url)
  end

  # create a new bin
  def create(bin_params)
    @rest.post('save', bin_params)
  end

  # create revision for bin
  def create_revision(id, bin_params)
    @rest.post("#{id}/save", bin_params)
  end
end