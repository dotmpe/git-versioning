# special rule targets
STRGTS := \
   default \
   info \
   test \
   build \
   install \
   update \
   version \
   check \
   increment \
   publish

.PHONY: $(STRGTS)

# BSD weirdness
echo = /bin/echo

empty :=
space := $(empty) $(empty)
default: info
	@echo 'usage:'
	@echo '# npm [info|update|test]'
	@echo '# make [$(subst $(space),|,$(STRGTS))]'

install:
	npm install
	make test

test: check

update:
	./tools/cli-version.sh update
	npm update
	bower update

build: TODO.list

TODO.list: Makefile lib ReadMe.rst reader.rst package.yaml Sitefile.yaml
	grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@

info:
	@./tools/cli-version.sh

version:
	@./tools/cli-version.sh version

check:
	@$(echo) -n "Checking for version "
	@./tools/cli-version.sh check

patch: m :=
patch:
	@./tools/cli-version.sh increment
	@git add -u && git ci -m '$(m)'

# XXX: GIT publish
publish: DRY := yes
publish: check
	@[ -z "$(VERSION)" ] && exit 1 || echo Publishing $(./tools/cli-version.sh version)
	git push
	@if [ $(DRY) = 'no' ]; \
	then \
		git tag v$(VERSION)
		git push fury master; \
		npm publish --tag $(VERSION); \
		npm publish; \
	else \
		echo "*DRY* $(VERSION)"; \
	fi


