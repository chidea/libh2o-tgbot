## libh2o-tgbot mruby-dict : A sample Telegram bot with H2O mruby script

### Features
- Multilingual dictionary

### Telegram bot link
[@CJKIdiomsBot](https://telegram.me/CJKIdiomsBot)

> Try `hua she tian zu` when your language is set to English (send `/lang en` to set to it manually)

### How to install
- Run redis-server on default port 
- Run redis script setup
```shell
  cd scripts; chmod +x *.sh; ./redis.sh
```
  - internally runs both `redis-data.sh` `redis-scripts.sh`
    - `redis-data.sh` simply reads idiom-redis.txt and put it into redis-cli
    - `redis-scripts.sh` compiles Redis LUA scripts into redis-cli and save them in ruby script variable format to be included from mruby
- Edit config
  - edit `example-h2o.conf` and fill up your directory location, domain name and save it to `h2o.conf`
  - edit `src/dict-config.rb` and fill up your domain name and telegram token

### How to run
- On every new redis-server instances, `redis-scripts.sh` must be executed before starting H2O
```shell
  cd scripts; ./redis-scripts.sh
```
- After that, start h2o instance
```shell
  h2o -c h2o.conf
```

### Webhook initialization on first run
- Send request to `https://<your-server-url>/init` within server to set webhook on telegram server
```shell
  curl https://<your-server-url>/init
```
