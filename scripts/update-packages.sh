#!/usr/bin/env bash
# Apply the fleet-wide package-version bumps that were identified on 2026-06-21.
#
# Requires: bootstrap.sh already run (Baton + all simulation repos cloned).
# Usage:    ./scripts/update-packages.sh
#           ./scripts/update-packages.sh --dry-run   # print commands, change nothing

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
FLEET="$ROOT/Baton/scripts/fleet-exec.sh"

DRY_RUN=""
for arg in "$@"; do [[ "$arg" == "--dry-run" ]] && DRY_RUN="--dry-run"; done

run() {
  echo "+ $*"
  [[ -n "$DRY_RUN" ]] && return
  "$@"
}

# ── All simulations ────────────────────────────────────────────────────────────
# @types/node: ^24.0.0 → ^24.13.2  (latest in the 24.x branch)
run "$FLEET" $DRY_RUN --simulation -- \
  npm pkg set 'devDependencies.@types/node=^24.13.2'

# sharp: ^0.35.1 → ^0.35.2
run "$FLEET" $DRY_RUN --simulation -- \
  npm pkg set 'devDependencies.sharp=^0.35.2'

# ── Repos that include vitest ──────────────────────────────────────────────────
# vitest: ^4.1.8 → ^4.1.9
for sim in MazeGame OpticsLab WaveComposer Resonance; do
  run npm $DRY_RUN --prefix "$ROOT/$sim" pkg set 'devDependencies.vitest=^4.1.9'
done

# @vitest/coverage-v8: ^4.1.8 → ^4.1.9  (Resonance only)
run npm $DRY_RUN --prefix "$ROOT/Resonance" pkg set \
  'devDependencies.@vitest/coverage-v8=^4.1.9'

# ── Baton ──────────────────────────────────────────────────────────────────────
# sharp: ^0.35.1 → ^0.35.2
run npm $DRY_RUN --prefix "$ROOT/Baton" pkg set 'devDependencies.sharp=^0.35.2'

# playwright: ^1.60.0 → ^1.61.0
run npm $DRY_RUN --prefix "$ROOT/Baton" pkg set 'devDependencies.playwright=^1.61.0'

echo
echo "Done. Run 'npm install' in each repo to lock the new versions."
