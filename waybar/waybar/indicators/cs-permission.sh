#!/usr/bin/env bash
set -euo pipefail

if [[ -f /tmp/cs2-permission-pending ]]; then
  printf '{"text":" ","class":"active","tooltip":"OpenCode permission requested"}\n'
else
  printf '{"text":"","class":"inactive","tooltip":""}\n'
fi
