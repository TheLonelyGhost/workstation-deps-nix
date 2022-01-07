
.PHONY: test
test:
	nix flake check

.PHONY: update
update:
	@echo Not yet implemented
	@exit 1

.PHONY: upgrade
upgrade: update
	@# alias helper for 'update'
	@true
