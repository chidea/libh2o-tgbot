$tg_token =''
$server_url = ''
require 'dict-config'

$redis_get_kor_by_id=''
$redis_get_kor_by_kor_name=''
$redis_get_kor_by_chi_name=''
require 'dict-redis-scripts'

require 'h2o'

class TGBot < Server
  def initialize(token, url)
    @token, @url = token, url
  end
  def sendMessage(id, text, replyTo=0)
    args = {chat_id:id, text:text}
    args['replyTo'] = replyTo if replyTo != 0
    tg('sendMessage', args)
  end
  def tg(method, arg={})
    body = if arg.empty? then '' else JSON.stringify(arg) end
    status, headers, body = http_request("https://api.telegram.org/bot#{@token}/#{method}", {method:'POST', headers:{'content-type'=> 'application/json'}, body:body}).join
    
    if status == 200
      JSON.parse body.join
    else
      nil
    end
  end
  def call(env)
    super
    if self.from_local?
      case @path
      when '/test'
        rst = ''
        return [200, {'content-type' => 'text/plain; charset=utf-8'}, [rst]]
      when '/init'
        r = tg('setWebhook', {url: "#{@url}#{@token}"})
        if not r
          return [501, {'content-type' => 'text/plain'}, ['internal error - setWebhook fail']]
        else
          return [200, {'content-type' => 'text/plain'}, [r['description']]]
        end
      when '/link'
        r = tg('getMe')
        if r
          return [403, {}, ['Forbidden - not a bot account']] unless r['result']['is_bot']
          username = r['result']['username']
          return [200, {'content-type' => 'text/html'}, ["<a href=\"https://t.me/#{username}\">add bot</a><br>"]]
        else
          return [501, {'content-type' => 'text/plain'}, ['internal error - getMe fail']]
        end
      end
    end
    case @path
    when "/#{@token}" # telegram bot webhook
      u = JSON.parse(@body)
      if u.key? 'inline_query'
        text = u['inline_query']['query']
        uid = u['inline_query']['from']['id']
        search = $dictR.evalsha($redis_get_mean_by_sound, 2, text, uid).join
        search = $dictR.evalsha($redis_get_mean_by_zh, 2, text, uid).join if search == nil
        # result construction for inline query
        rst = {method:'answerInlineQuery', inline_query_id:u['inline_query']['id'], results:[{type:'article', id:text, title:text, input_message_content:{message_text:search}}]}
      elsif u.key? 'message' and u['message'].key? 'text'
        case u['message']['text']
        when /\A\/(lang|start)([ ]+([a-z]{2}))?\z/
          #$stderr.puts 'following user started CJK idioms dictionary'
          #$stderr.puts u
          uid = "user:#{u['message']['from']['id']}"
          $stderr.puts uid
          lang = $3!=nil ? $3 : u['message']['from']['language_code']
          lang_cnt = $dictR.evalsha($redis_get_lang, 1, lang).join
          if lang_cnt == 0
            lang = 'en' 
            lang_cnt = $dictR.evalsha($redis_get_lang, 1, lang).join
          end
          $dictR.hset(uid, 'lang', lang)
          $dictR.bgsave
          lang_name = $dictR.hget('langname', lang).join
          rst = "User language set to #{lang_name} which supports #{lang_cnt} idioms.\nYou can manually change language setting with `/lang <language_code>` command. Visit https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes for language codes.\nSend inline query or message to this bot to search CJK idioms in your language."
        when /\A\/id ([0-9]+)\z/
          rst = $dictR.evalsha($redis_get_mean_by_id, 2, $1, u['message']['from']['id']).join
          rst = rst!=nil ? rst : 'could not find idiom'
        else
          rst = $dictR.evalsha($redis_get_mean_by_sound, 2, u['message']['text'], u['message']['from']['id']).join
          rst = $dictR.evalsha($redis_get_mean_by_zh, 2, u['message']['text'], u['message']['from']['id']).join if rst == nil
          rst = rst!=nil ? rst : 'could not find idiom'
        end
        # result construction for normal chat message
        rst = {method:'sendMessage', chat_id:u['message']['chat']['id'], text: rst}
      end
      # result construction for telegram web hook
      return [200, {'content-type' => 'application/json; charset=utf-8'}, [JSON.stringify(rst)]]
    else
      [403, {}, ['Forbidden']]
    end
  end
end

TGBot.new($tg_token, $server_url)
