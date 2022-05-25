test: tests/run/id_rsa
	prove tests/

tests/run/id_rsa tests/run/id_rsa.pub: tests/run/.dir
	ssh-keygen -f tests/run/id_rsa -N ''

tests/run/.dir:
	mkdir -p tests/run/
	touch tests/run/.dir

clean:
	rm -rf tests/run/
