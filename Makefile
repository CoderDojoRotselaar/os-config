LIBRARIAN_CMD=librarian-puppet

install-modules:
	$(LIBRARIAN_CMD) install --verbose

update-modules:
	$(LIBRARIAN_CMD) update --verbose

bump: update-modules
	git add Puppetfile.lock
	git ci -m "Bump modules"
	git push

