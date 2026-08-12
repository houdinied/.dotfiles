#!/usr/bin/env bash
set -euo pipefail

# Drain stdin so Codex can send the hook payload without blocking.
cat >/dev/null

# Leave CS2_REACTION_SOUND unset so cs2-reaction picks a random .wav from
# ~/.local/share/cs2-reactions instead of always playing the same "yes" clip.
"$HOME/.local/bin/cs2-reaction" --notify "Codex permission" "Approval requested"
