# Id: git-versioning/0.0.16-dev+20150430-2146 Rules.git-versioning.mk

include $(DIR)/Rules.git-versioning.shared.mk

# special rule targets
STRGT += \
   usage \
   install \
   test \
   update \
   build

DEFAULT := usage
empty :=
space := $(empty) $(empty)
usage:
	@echo 'usage:'
	@echo '# npm [info|update|test]'
	@echo '# make [$(subst $(space),|,$(STRGT))]'

install::
	npm install
	make test

test: check

update:
	./bin/cli-version.sh update
	npm update
	bower update

build:: TODO.list

TODO.list: Makefile lib ReadMe.rst reader.rst package.yaml Sitefile.yaml
	grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@

