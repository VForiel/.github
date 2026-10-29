# 🏡 Default community files

GitHub uses the files of this repository for every public repository of
[VForiel](https://github.com/VForiel) that does not have its own version:

| File | Role |
|---|---|
| 🤝 [`CONTRIBUTING.md`](CONTRIBUTING.md) | How to report a problem or propose a change |
| 🌈 [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | How we treat each other |
| 🔒 [`SECURITY.md`](SECURITY.md) | How to report a vulnerability privately |
| 🛟 [`SUPPORT.md`](SUPPORT.md) | Where to ask a question |
| 💖 [`FUNDING.yml`](FUNDING.yml) | The "Sponsor" button |
| 📋 [`ISSUE_TEMPLATE/`](ISSUE_TEMPLATE) | Issue forms: bug, feature, question |
| 🔀 [`PULL_REQUEST_TEMPLATE.md`](PULL_REQUEST_TEMPLATE.md) | Pull request checklist |

A repository with its own file (for example `CONTRIBUTING.md` in PHISE, or its own `.github/ISSUE_TEMPLATE/`)
keeps it: the project's rules come first.

## 🏷️ Labels

GitHub does not share labels between the repositories of a personal account. [`labels.yml`](labels.yml) lists the
common set and [`scripts/sync-labels.sh`](scripts/sync-labels.sh) creates or updates them, and renames the plain
GitHub labels (`bug` → `🐛 bug`) so that issues keep them; it never deletes a label:

```bash
scripts/sync-labels.sh              # every public repository that is not archived or a fork
scripts/sync-labels.sh LUMOS PHISE  # only these
```

It needs the [GitHub CLI](https://cli.github.com/) (`gh auth login`) and Python 3.
