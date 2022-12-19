NIX := nix
STATIX := statix

UPDATED_FLAKE_INPUTS = tag
FLAKE_INPUTS = $(foreach i,$(UPDATED_FLAKE_INPUTS),--update-input $(i) )

.PHONY: test
test:
	$(STATIX) check
	$(NIX) flake check

.PHONY: update
update:
	$(NIX) flake lock $(FLAKE_INPUTS)

.PHONY: upgrade
upgrade: update
	@# alias helper for 'update'
	@true
