require 'riddle'
require 'riddle/2.0.1'

module Thebes

  class Query < Riddle::Client
    cattr_accessor :before_query,
                   :before_running,
                   :servers

    def initialize(*args)
      if !args.empty? || self.class.servers.empty?
        super(*args)
      else
        host, port = self.class.servers.sample
        super(host, port)
      end
    end

    def servers
      @servers
    end

    class << self
      def run(&block)
        client = new # would take server and port
        before_query.call(client) if before_query
        yield client if block_given?
        before_running.call(client) if before_running
        client.run
      end
    end
  end
end
