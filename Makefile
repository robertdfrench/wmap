test: tests/run/id_rsa tests/run/id_rsa.pub tests/run/message preflight
	prove -I tests tests

preflight: example/message.json example/message.json.sig tests/allowed_signers
	ssh-keygen -Y verify \
		-f tests/allowed_signers \
		-I "https://github.com/robertdfrench" \
		-n "wmap@wmap.dev" \
		-s example/message.json.sig < example/message.json

tests/run/id_rsa tests/run/id_rsa.pub: tests/run/.dir
	ssh-keygen -f tests/run/id_rsa -N ''

tests/run/message: tests/run/.dir
	echo "Hello, World" > $@

tests/run/.dir:
	mkdir -p $(dir $@)
	touch $@

clean:
	rm -rf tests/run
