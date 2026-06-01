# CI/CD Integration

docpilot can run as part of your CI/CD pipeline to keep documentation synchronized with code changes.

## GitHub Actions Example

Create `.github/workflows/docs.yml`:

```yaml
name: Update Documentation

on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - '!docs/**'

jobs:
  update-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Install docpilot skill
        run: |
          mkdir -p ~/.claude/skills
          curl -fsSL https://raw.githubusercontent.com/airwaves778899/docpilot/main/skill/SKILL.md \
            -o ~/.claude/skills/docpilot.md

      - name: Run docpilot (verify and correct existing docs)
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude -p "
          Run docpilot Operation B (verify and correct existing documentation).
          Source code root: $GITHUB_WORKSPACE/src
          Docs root: $GITHUB_WORKSPACE/docs
          Scope: only files changed in this commit
          Language: English
          Do not ask for confirmation — proceed automatically.
          "

      - name: Commit updated docs
        run: |
          git config --local user.email "docs-bot@github.com"
          git config --local user.name "docpilot"
          git add docs/
          git diff --staged --quiet || git commit -m "docs: auto-update via docpilot [skip ci]"
          git push
```

## What This Does

On every push to `main` that changes `src/`:
1. Installs Claude Code and the docpilot skill
2. Runs docpilot in verification mode against changed files
3. Commits any documentation corrections back to the repo

## Important Notes

- Use `[skip ci]` in the commit message to prevent infinite loops
- Store your `ANTHROPIC_API_KEY` in GitHub Secrets
- Adjust `src/**` and `docs/**` paths to match your project structure
- Consider running on PRs instead of `main` for review before merging

## GitLab CI Example

```yaml
update-docs:
  stage: docs
  image: node:20
  only:
    changes:
      - src/**/*
  script:
    - npm install -g @anthropic-ai/claude-code
    - mkdir -p ~/.claude/skills
    - curl -fsSL .../install.sh | bash
    - claude -p "run docpilot verify on $CI_PROJECT_DIR/src docs at $CI_PROJECT_DIR/docs"
  artifacts:
    paths:
      - docs/
```
