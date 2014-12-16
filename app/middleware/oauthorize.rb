class Oauthorize
  def initialize(app, opts = {})
    @app = app
    @opts = opts
  end

  def call(env)
    @status, @headers, @response = @app.call(env)

    [@status, @headers, self]
  end
end