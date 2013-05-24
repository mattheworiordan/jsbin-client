class JsBinClient
  class AuthenticationRequired < StandardError; end
  class OwnershipError < StandardError; end
  class BinMissing < StandardError; end
  class InvalidJson < StandardError; end
end