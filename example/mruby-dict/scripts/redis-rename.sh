#redis-cli --scan --pattern idiom:*:kor  | \
  #awk '/^/ {new_key=$1;gsub(/kor/,"ko", new_key); printf "*3\r\n$6\r\nrename\r\n$" length($1) "\r\n" $1 "\r\n$" length(new_key) "\r\n"  new_key "\r\n";}'  | \
#redis-cli --pipe

#redis-cli --scan --pattern idiom:*  | \
  #awk '/^/ {cmd = "echo " $0 "|wc -c"; cmd | getline bcnt; close(cmd); printf "*2\r\n$3\r\ndel\r\n$" bcnt-1 "\r\n" $1 "\r\n";}' | \
#redis-cli --pipe
