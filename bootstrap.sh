#!/usr/bin/env bash
# Bootstrap the OpenPhysics workspace.
#
# This superproject is a thin aggregator with no submodules. Running this script
# clones the org's orchestration repo (Baton) and then hands off to Baton's
# clone-fleet.sh, which reads the catalog (Baton/structure/repos.json) and clones
# every member repo as a sibling directory right here.
#
# Re-runnable: repos already present are left untouched (pass --update to
# fast-forward them). All arguments are forwarded to clone-fleet.sh, so its
# filters and options work here too.
#
# Examples:
#   ./bootstrap.sh                 # clone whatever is missing
#   ./bootstrap.sh --simulation    # just the simulations
#   ./bootstrap.sh --update        # also fast-forward repos already cloned
#   ./bootstrap.sh --dry-run       # show the plan, change nothing
#   ./bootstrap.sh --https         # clone over HTTPS instead of SSH
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG="OpenPhysics"
BATON_URL="git@github.com:${ORG}/Baton.git"

# Match Baton's clone scheme to the one requested for the rest of the fleet.
for arg in "$@"; do
  [[ "$arg" == "--https" ]] && BATON_URL="https://github.com/${ORG}/Baton.git"
done

command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }

# Baton carries the catalog and the clone logic, so it has to come first.
if [[ -d "$ROOT/Baton/.git" ]]; then
  echo "Baton already present."
else
  echo "Cloning Baton (orchestration + catalog)…"
  git clone --quiet "$BATON_URL" "$ROOT/Baton"
fi

# Keep the catalog current before handing off. Baton carries structure/repos.json,
# the single source of truth for which repos clone-fleet.sh knows about. A stale
# checkout here makes newly-onboarded repos invisible — clone-fleet will happily
# report "nothing to clone" against an old catalog. Fast-forward only, so local
# work in Baton is never lost; if Baton has diverged or we are offline, warn and
# continue with whatever is on disk.
if ! git -C "$ROOT/Baton" pull --ff-only --quiet 2>/dev/null; then
  cat >&2 <<'EOF'
warning: could not fast-forward Baton (it has diverged, or the network is offline).
         The fleet catalog may be stale — newly added repos won't be cloned.
         Fix with: cd Baton && git pull --ff-only
EOF
fi

exec "$ROOT/Baton/scripts/clone-fleet.sh" "$@"
