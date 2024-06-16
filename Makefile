venv=. .venv/bin/activate &&

test: lint typecheck check

check: .venv/ready
	$(venv) pytest --cov=. --cov-fail-under=100

lint: .venv/ready
	$(venv) flake8 wmap tests/test_wmap.py

typecheck: .venv/ready
	$(venv) mypy wmap

.venv/ready: dev-requirements.txt .venv/update
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
