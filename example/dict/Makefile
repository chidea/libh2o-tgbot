all: build

build: src/main.c
	gcc src/main.c -lh2o -lssl -lcrypto -luv -pthread -lz -L/usr/local/lib -lm -o bin/dict -fno-stack-protector

run: bin/dict
	sudo bin/dict

stop:
	sudo pkill dict

test: test/test.c
	gcc test/test.c -lh2o -lssl -lcrypto -luv -pthread -lz -L/usr/local/lib -lm -o bin/test -fno-stack-protector
