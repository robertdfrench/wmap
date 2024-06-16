venv=. .venv/bin/activate &&

test: .venv/ready
	$(venv) pytest

.venv/ready: requirements.txt .venv/update
	$(venv) pip install -r $<
	touch $@

.venv/update: .venv/init
	$(venv) pip install --upgrade pip
	touch $@

.venv/init:
	python3 -m venv .venv
	touch $@

clean:
	rm -rf .venv
