test: clean
	@for t in tests/*.sh; do echo "$${t}"; ./"$${t}"; done

clean:
	rm -rf tests/run/
