LIBRARIAN_CMD=docker run --rm --entrypoint=/usr/bin/r10k -u $(shell id -u):$(shell id -g) -v $(shell pwd)/.r10k:/.r10k -v $(shell pwd)/:/home/puppet/ puppet/r10k

r10k:
	$(LIBRARIAN_CMD) $(CMD)

install-modules:
	$(LIBRARIAN_CMD) puppetfile install --verbose

bump: install-modules
	git add Puppetfile.lock
	git ci -m "Bump modules"
	git push

