$LOAD_PATH << File.dirname(__FILE__)

#require 'mruby-json'

$tg_token =''
$server_url = ''
require 'dict-config.rb'

class TGBot
  def initialize(token, url)
    puts 'Bot.init called'
    @token = token
    @url = url
    #tg('setWebhook')
  end
  def sendMessage(id, text, replyTo=0)
    args = {chat_id:id, text:text}
    args['replyTo'] = replyTo if replyTo != 0
    tg('sendMessage', args)
  end
  def tg(method, arg={})
    if arg.length == 0
      body=''
    else
      body=JSON.stringify(arg)
    end
    status, headers, body = http_request("https://api.telegram.org/bot#{@token}/#{method}", {method:'POST', headers:{'content-type'=> 'application/json'}, body:body}).join #x-www-form-urlencoded
    #,{method header body}
    
    if status == 200
      JSON.parse body.join
    else
      false
    end
  end
  def call(env)
    path = env['PATH_INFO']
    if /\A192\.168\.0\./.match(env['REMOTE_ADDR'])
      if '/test' == path
        #return [200, {'content-type' => 'text/plain'}, [File.dirname(__FILE__)]]
        args = {method:'POST', headers:{'content-type'=> 'application/json'}}
        args['body'] = JSON.stringify({url:'asdf'})
        return [200, {'content-type' => 'text/plain'}, [args['body']]]
        #return [200, {'content-type' => 'text/plain'}, [URI.parse(args['body'])]]
        #return [200, {'content-type' => 'text/plain'}, [JSON.stringify({'url' => "https://dict.idea.sh/#{@token}"})]]
      elsif '/init' == path
        r = tg('setWebhook', {url: "#{@url}#{@token}"})
        if not r
          return [501, {'content-type' => 'text/plain'}, ['internal error - setWebhook fail']]
        else
          return [200, {'content-type' => 'text/plain'}, [r['description']]]
        end
      elsif '/link' == path
        r = tg('getMe')
        if r
          if not r['result']['is_bot']
            return [403, {}, ['Forbidden - not a bot account']]
          end
          username = r['result']['username']
          return [200, {'content-type' => 'text/html'}, ["<a href=\"https://t.me/#{username}\">add bot</a><br>"]]
        else
          return [501, {'content-type' => 'text/plain'}, ['internal error - getMe fail']]
        end
      end
    end
    if "/#{@token}" == path  # webhook
      input = env['rack.input'].read
      u = JSON.parse(input)
      if u['message']['text'] == '/start'
        u['replied'] = sendMessage(u['message']['chat']['id'], 'hello! this bot is currently under construction!')
      end
      u['at'] = Time.now.to_i
      return [204, {'x-fallthru-set-POSTDATA'=>JSON.stringify(u)}, []]
      #[200, {}, []]
    end
    [400, {}, ['400 Bad Request']]
  end
end

TGBot.new($tg_token, $server_url)
