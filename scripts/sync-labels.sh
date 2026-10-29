#!/usr/bin/env bash
# Create or update the labels of labels.yml in VForiel's repositories (never deletes a label).
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

# labels.yml holds one "- name / color / description" entry per label: read it as tab-separated lines.
mapfile -t labels < <(python - "$labels_file" <<'EOF'
import sys
entry = {}
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    key, _, value = line.lstrip("- ").partition(":")
    if line.startswith("- ") and entry:
        print(entry["name"], entry["color"], entry["description"], sep="\t")
        entry = {}
    entry[key.strip()] = value.strip()
if entry:
    print(entry["name"], entry["color"], entry["description"], sep="\t")
EOF
)

for repo in "${repos[@]}"; do
    echo "$owner/$repo"
    for label in "${labels[@]}"; do
        IFS=$'\t' read -r name color description <<< "${label%$'\r'}"
        gh label create "$name" --repo "$owner/$repo" --color "$color" --description "$description" --force > /dev/null
    done
done
