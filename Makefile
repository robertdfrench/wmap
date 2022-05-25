test: t/run/id_rsa
	prove

t/run/id_rsa t/run/id_rsa.pub: t/run/.dir
	ssh-keygen -f t/run/id_rsa -N ''

t/run/.dir:
	mkdir -p t/run/
	touch t/run/.dir

clean:
	rm -rf t/run/
