test: tests/run/id_rsa tests/run/id_rsa.pub tests/run/message
	which rev
	prove -I tests tests

tests/run/id_rsa tests/run/id_rsa.pub: tests/run/.dir
	ssh-keygen -f tests/run/id_rsa -N ''

tests/run/message: tests/run/.dir
	echo "Hello, World" > $@

tests/run/.dir:
	mkdir -p $(dir $@)
	touch $@

clean:
	rm -rf tests/run
