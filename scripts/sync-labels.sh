#!/usr/bin/env bash
# Create or update the labels of labels.yml in VForiel's repositories (never deletes a label).
# A label still under its former name ("was") is renamed, so that the issues keep it.
# Usage: scripts/sync-labels.sh [repo ...]   (default: every public repository that is not archived or a fork)
set -euo pipefail

owner=VForiel
labels_file="$(dirname "$0")/../labels.yml"

if [ "$#" -gt 0 ]; then
    repos=("$@")
else
    mapfile -t repos < <(gh repo list "$owner" --visibility public --no-archived --source --limit 200 \
        --json name,hasIssuesEnabled --jq '.[] | select(.hasIssuesEnabled) | .name' | tr -d '\r')
fi

# labels.yml holds one "- name / was / color / description" entry per label: read it as tab-separated lines.
mapfile -t labels < <(python - "$labels_file" <<'EOF'
import sys
sys.stdout.reconfigure(encoding="utf-8")  # emojis, whatever the console code page
entries, entry = [], {}
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    if line.startswith("- ") and entry:
        entries.append(entry)
        entry = {}
    key, _, value = line.removeprefix("- ").partition(":")
    entry[key.strip()] = value.strip()
entries.append(entry)
for entry in entries:
    print(entry["name"], entry.get("was", ""), entry["color"], entry["description"], sep="\t")
EOF
)

for repo in "${repos[@]}"; do
    echo "$owner/$repo"
    existing="$(gh label list --repo "$owner/$repo" --limit 200 --json name --jq '.[].name' | tr -d '\r')"
    for label in "${labels[@]}"; do
        IFS=$'\t' read -r name was color description <<< "${label%$'\r'}"
        if [ -n "$was" ] && grep -qxF "$was" <<< "$existing" && ! grep -qxF "$name" <<< "$existing"; then
            gh label edit "$was" --repo "$owner/$repo" --name "$name" --color "$color" --description "$description" > /dev/null
        else
            gh label create "$name" --repo "$owner/$repo" --color "$color" --description "$description" --force > /dev/null
        fi
    done
done
