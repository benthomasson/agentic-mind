.PHONY: install-tools install-skills setup

install-tools:
	uv tool install git+https://github.com/benthomasson/entry
	uv tool install git+https://github.com/benthomasson/beliefs
	uv tool install git+https://github.com/benthomasson/checkpoint

install-skills:
	entry install-skill
	beliefs install-skill
	checkpoint install-skill

setup: install-tools install-skills
	entry init
	@echo ""
	@echo "Done. Next step:"
	@echo "  Append CLAUDE.md to ~/.claude/CLAUDE.md"
	@echo "  cat CLAUDE.md >> ~/.claude/CLAUDE.md"
