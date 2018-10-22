module ImageHost
  abstract class Exception
  end
  class EmptyBody < Exception
    def initialize(ctx : HTTP::Server::Context)
      super "Request #{ctx.request.inspect} had no body_io to read from!"
    end
  end
end
