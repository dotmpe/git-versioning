# special rule targets
STRGTS := \
   default \
   info \
   lint \
   test \
   build \
   install \
   update \
   publish

.PHONY: $(STRGTS)

empty :=
space := $(empty) $(empty)
default:
	@echo 'usage:'
	@echo '# npm [info|update|test]'
	@echo '# make [$(subst $(space),|,$(STRGTS))]'

install:
	npm install
	make test

lint:
	grunt lint

# FIXME jasmine from grunt?
test:
	#coffee test/runner.coffee

update:
	npm update
	bower update

build: TODO.list

TODO.list: Makefile bin config public lib test ReadMe.rst Gruntfile.js Sitefile.yaml
	grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@

info:
	npm run srctree
	npm run srcloc


VERSION :=

publish: DRY := yes
publish:
	@[ -z "$(VERSION)" ] && exit 1 || echo Publishing $(VERSION)
	grep version..$(VERSION) ReadMe.rst
	@./check.coffee $(VERSION)
	grep '^$(VERSION)' Changelog.rst
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


