# LIBRARIAN_CMD=docker run --rm -u $(shell id -u):$(shell id -g) -v $(shell pwd):/work librarian-puppet
LIBRARIAN_CMD=librarian-puppet

.PHONY: all test clean librarian

install-modules:
	$(LIBRARIAN_CMD) install --verbose

update-modules:
	$(LIBRARIAN_CMD) update --verbose

bump: update-modules
	git add Puppetfile.lock
	git ci -m "Bump modules"
	git push

librarian:
	docker build --pull=true -t librarian-puppet librarian/
