require 'faraday'

module EyecueIpayout
  module Request
    class Gateway < Faraday::Middleware

      def call(env)
        puts "!!!!!!EyecueIpayout::Gateway -> call"
        url = env[:url].dup
        url.host = @gateway
        env[:url] = url
        @app.call(env)
      end

      def initialize(app, gateway)
        puts "!!!!!!EyecueIpayout::Gateway -> initialize"
        @app, @gateway = app, gateway
      end
    end
  end
end
