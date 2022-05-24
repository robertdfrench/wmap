test: t/run/
	prove

t/run/:
	mkdir -p $@

clean:
	rm -rf t/run/
