.PHONY: install-tools install-skills install-skills-gemini setup setup-gemini

install-tools:
	uv tool install git+https://github.com/benthomasson/entry
	uv tool install git+https://github.com/benthomasson/beliefs
	uv tool install git+https://github.com/benthomasson/checkpoint

install-skills:
	entry install-skill
	beliefs install-skill
	checkpoint install-skill

install-skills-claude:
	mkdir -p ~/.claude/skills
	entry install-skill --skill-dir ~/.claude/skills
	beliefs install-skill --skill-dir ~/.claude/skills
	checkpoint install-skill --skill-dir ~/.claude/skills

install-skills-gemini:
	mkdir -p ~/.gemini/skills
	entry install-skill --skill-dir ~/.gemini/skills
	beliefs install-skill --skill-dir ~/.gemini/skills
	checkpoint install-skill --skill-dir ~/.gemini/skills

setup: install-tools install-skills
	entry init
	@echo ""
	@echo "Done. Next step:"
	@echo "  Append CLAUDE.md to ~/.claude/CLAUDE.md"
	@echo "  cat CLAUDE.md >> ~/.claude/CLAUDE.md"

setup-gemini: install-tools install-skills-gemini
	entry init
	@echo ""
	@echo "Done. Next step:"
	@echo "  Append CLAUDE.md to ~/.gemini/GEMINI.md (or gemini.md)"
	@echo "  cat CLAUDE.md >> ~/.gemini/GEMINI.md"
