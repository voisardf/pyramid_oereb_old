ifeq ($(CI),true)
  PYTHON_VENV=do_pip
  VENV=
else
  PYTHON_VENV=.venv/timestamp
  VENV_BIN=.venv/bin/
endif

install: $(PYTHON_VENV)

.venv/timestamp: setup.py requirements.txt
	/usr/bin/virtualenv --python=/usr/bin/python2.7 .venv
	.venv/bin/pip install --upgrade -r requirements.txt
	touch $@

.PHONY: do_pip
do_pip:
	pip install --upgrade -r requirements.txt

.PHONY: checks
checks: git-attributes lint tests

.PHONY: tests
tests: $(PYTHON_VENV)
	$(VENV_BIN)py.test -vv pyramid_oereb/tests

.PHONY: lint
lint: $(PYTHON_VENV)
	$(VENV_BIN)flake8

.PHONY: git-attributes
git-attributes:
	git --no-pager diff --check `git log --oneline | tail -1 | cut --fields=1 --delimiter=' '`


.PHONY: setup_db
setup_db:
	psql -c 'CREATE DATABASE oereb_test;' -U postgres
	psql -c "CREATE USER \"www-data\" PASSWORD 'www-data';" -U postgres oereb_test || true
	psql -c 'CREATE TABLE example (id SERIAL PRIMARY KEY, value TEXT);' -U postgres oereb_test
	psql -c "INSERT INTO example (value) VALUES ('test');" -U postgres oereb_test
	psql -c 'grant ALL on example to "www-data"' -U postgres oereb_test

.PHONY: drop_db
drop_db:
	psql -c 'DROP DATABASE oereb_test;' -U postgres
