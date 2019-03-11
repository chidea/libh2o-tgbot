#$LOAD_PATH << File.dirname(__FILE__)

class Server
  def call(env)
    @path, @raddr = env['PATH_INFO'], env['REMOTE_ADDR']
    @body = env['rack.input'] ? env['rack.input'].read : ''
    @method = env['REQUEST_METHOD']
  end
  def decode_body()
    URI.decode_www_form(@body)
  end
  def from_local?()
    if '127.0.0.1' == @raddr or 'localhost' == @raddr or /\A192\.168\./.match(@raddr) then true else false end
  end
end
