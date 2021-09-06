LIBRARIAN_CMD=docker run --rm -u0 -v $(shell pwd)/:/home/puppet/ puppet/r10k

install-modules:
	$(LIBRARIAN_CMD) puppetfile install --verbose

bump: install-modules
	git add Puppetfile.lock
	git ci -m "Bump modules"
	git push

