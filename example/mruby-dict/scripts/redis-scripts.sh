OUTFILE=../src/dict-redis-scripts.rb

redis-cli script flush
echo '' > $OUTFILE

redis-cli script load "
local key = redis.call('keys', 'sound:*:'..KEYS[1]..':*')
return #key
" | perl -pe 's/(.+)/\$redis_get_lang="$1"/' >> $OUTFILE

# local _, len = string.gsub(ko, '[^\128-\193]', '')  #unicode length

redis-cli script load "
local lang = redis.call('hget', 'user:'..KEYS[2], 'lang')
local key = redis.call('keys', 'idiom:'..KEYS[1]..':cnt:*')
if #key > 0 then
  key = key[1]
  local sound = redis.call('keys', string.format('sound:%s:%s:*', KEYS[1], lang))
  if #sound >0 then
    sound = sound[1]
  else
    sound = redis.call('keys', string.format('sound:%s:ko:*', KEYS[1]))[1]
  end
  local numlen = math.floor(math.log10(KEYS[1])+1)
  sound = string.sub(sound, 7+numlen+4)
  local zh = string.sub(key, 7+numlen+1+3+1)
  local meankey = string.format('mean:%s', KEYS[1])
  if not redis.call('hexists', meankey, lang) then
    lang = 'ko'
  end
  local mean = redis.call('hget', meankey, lang)
  return string.format('[%s]%s - %s - %s', KEYS[1], sound, zh, mean)
else
  return nil
end
" | perl -pe 's/(.+)/\$redis_get_mean_by_id="$1"/' >> $OUTFILE

redis-cli script load "
local lang = redis.call('hget', 'user:'..KEYS[2], 'lang')
local key = redis.call('keys', 'idiom:*:cnt:'..KEYS[1])
if #key > 0 then
  key = key[1]
  redis.call('incr', key)
  local num = string.match(key,'%d+',7)
  local meankey = string.format('mean:%s', num)
  if not redis.call('hexists', meankey, lang) then
    lang = 'ko'
  end
  local mean = redis.call('hget', meankey, lang)
  local sound = redis.call('keys', string.format('sound:%s:%s:*', num, lang))[1]
  local numlen = string.len(num)
  sound = string.sub(sound, 7+numlen+1+2+1)
  return string.format('%s - %s - %s', KEYS[1], sound, mean)
else
  return nil
end
" | perl -pe 's/(.+)/\$redis_get_mean_by_zh="$1"/' >> $OUTFILE

redis-cli script load "
local lang = redis.call('hget', 'user:'..KEYS[2], 'lang')
local key = redis.call('keys', 'sound:*:'..lang..':'..KEYS[1])
if #key > 0 then
  key = key[1]
  local num = string.match(key,'%d+',7)
  local numlen = string.len(num)
  local zh = string.sub(redis.call('keys', 'idiom:'..num..':cnt:*')[1], 7+numlen+1+3+1)
  local meankey = string.format('mean:%s', num)
  if not redis.call('hexists', meankey, lang) then
    lang = 'ko'
  end
  local mean = redis.call('hget', meankey, lang)
  return string.format('%s - %s - %s', KEYS[1], zh, mean)
else
  return nil
end
" | perl -pe 's/(.+)/\$redis_get_mean_by_sound="$1"/' >> $OUTFILE
