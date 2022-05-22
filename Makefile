test: tests/run/id_rsa tests/run/id_rsa.pub tests/run/message toolcheck
	prove -I tests tests

tests/run/id_rsa tests/run/id_rsa.pub: tests/run/.dir
	ssh-keygen -f tests/run/id_rsa -N ''

tests/run/message: tests/run/.dir
	echo "Hello, World" > $@

tests/run/.dir:
	mkdir -p tests/run
	touch $@

TOOLCHECK=tests/run/toolcheck
toolcheck: \
	$(TOOLCHECK)/message \
	$(TOOLCHECK)/message.sig \
	$(TOOLCHECK)/allowed_signers
	ssh-keygen -Y verify \
		-f $(TOOLCHECK)/allowed_signers \
		-I toolcheck@localhost \
		-n "wmap@wmap.dev" \
		-s $(TOOLCHECK)/message.sig < $(TOOLCHECK)/message

$(TOOLCHECK)/message.sig: $(TOOLCHECK)/message $(TOOLCHECK)/id_rsa
	ssh-keygen -Y sign \
		-f $(TOOLCHECK)/id_rsa \
		-n "wmap@wmap.dev" \
		$(TOOLCHECK)/message

$(TOOLCHECK)/id_rsa $(TOOLCHECK)/id_rsa.pub: $(TOOLCHECK)/.dir
	ssh-keygen -f $(TOOLCHECK)/id_rsa -N ''

$(TOOLCHECK)/allowed_signers: $(TOOLCHECK)/id_rsa.pub
	cat $< | perl -aE 'say "toolcheck\@localhost namespaces=\"wmap\@wmap.dev\" " . $$F[0] . " " . $$F[1]' > $@

$(TOOLCHECK)/message: $(TOOLCHECK)/.dir
	echo "Hello, World" > $@

$(TOOLCHECK)/.dir:
	mkdir -p $(TOOLCHECK)
	touch $@

clean:
	rm -rf tests/run
