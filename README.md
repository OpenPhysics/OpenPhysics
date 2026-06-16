# OpenPhysics

Thin **workspace bootstrapper** for the [OpenPhysics](https://github.com/OpenPhysics)
organization. This repo tracks only a README and a `bootstrap.sh` script; it has **no
submodules**. Running the script clones the whole org — every simulation, the shared
infrastructure, and the hardware/tooling libraries — side by side in one directory, which is
exactly the layout the Baton scripts expect.

Each member repo stays a fully independent git repo with its own remote, branches, issues, and
release cadence. There are no submodule pointers to bump: [`Baton/structure/repos.json`](https://github.com/OpenPhysics/Baton/blob/main/structure/repos.json)
is the single source of truth for what the org contains.

## Setup

```bash
git clone git@github.com:OpenPhysics/OpenPhysics.git
cd OpenPhysics
./bootstrap.sh
```

`bootstrap.sh` clones `Baton` (which carries the catalog) and then hands off to
[`Baton/scripts/clone-fleet.sh`](https://github.com/OpenPhysics/Baton/blob/main/scripts/clone-fleet.sh),
which clones every repo in the catalog as a sibling directory here. It is **re-runnable** —
repos already present are skipped:

```bash
./bootstrap.sh                 # clone whatever is missing
./bootstrap.sh --simulation    # just the simulations
./bootstrap.sh --update        # also fast-forward repos already cloned
./bootstrap.sh --dry-run       # show the plan, change nothing
./bootstrap.sh --https         # clone over HTTPS instead of SSH
```

The cloned repos are git-ignored here, so `git status` in this superproject stays clean no
matter what state the member repos are in.

## Layout

After `./bootstrap.sh`, the workspace holds two infrastructure repos plus the member repos:

| Repo | Type | Purpose |
|---|---|---|
| [`.github`](https://github.com/OpenPhysics/.github) | config | Org community-health defaults (license, contributing, code of conduct, security, issue/PR templates, org profile) **plus** shared AI-assistant guidance (`CLAUDE.md`). GitHub requires these in the special `.github` repo. |
| [`Baton`](https://github.com/OpenPhysics/Baton) | tool | Org **orchestration**: reusable CI/CD workflows, the cross-repo automation scripts, Dependabot templates, the machine-readable repo catalog (`structure/repos.json`), fleet conventions (`CONVENTIONS.md`, `ACCESSIBILITY.md`), SceneryStack AI reference docs (`skills/`), and the GitHub Pages landing page. |
| `TemplateSingleSim` | template | Canonical starting point — new sims are forked from it and start accessible by default. |
| `DopplerEffect`, `ElectricFieldOfDreams`, `LadyBug`, `LunarLander`, `MazeGame`, `MovingMan`, `OpticsLab`, `OscillationsAndChaos`, `QubitSketch`, `RadioWaves`, `Resonance`, `TheRamp`, `TrackLab`, `WaveComposer` | simulation | SceneryStack TypeScript simulations. |
| `jscd48`, `tscd48`, `pycd48` | hardware-interface | CD48 hardware libraries (the JS/TS ones use MIT, not the org AGPL default). |
| `pyro` | tool | Python tooling. |

> **`.github` vs `Baton`:** `.github` holds only what GitHub *must* serve from the special repo
> (community health + org-wide `CLAUDE.md`). Everything operational — CI workflows, catalog,
> scripts, fleet conventions, SceneryStack AI skills, Pages — lives in `Baton`. Keep that split:
> don't add workflows to `.github` or community-health files to `Baton`.

`Baton/structure/repos.json` is the source of truth for what exists in the org. The bootstrapper,
the compliance audit, the Pages landing page, and every `Baton/scripts/*` tool read it. The
scripts default `OPENPHYSICS_WORKSPACE` to this directory, so they find sibling repos with no
extra configuration.

## Common tasks

```bash
# List the simulation repos
Baton/scripts/parse-repos.sh names --simulation

# Audit README + CI compliance for one sim
Baton/scripts/check-repo-compliance.sh DopplerEffect

# Preview a change across all sims (dry-run, opens nothing)
Baton/scripts/fleet-exec.sh --simulation -- npm pkg set dependencies.scenerystack=^3.1.0
```

See [`Baton/README.md`](https://github.com/OpenPhysics/Baton/blob/main/README.md) for
orchestration and [`Baton/scripts/README.md`](https://github.com/OpenPhysics/Baton/blob/main/scripts/README.md)
for the full tooling reference.

## Working in a member repo

Each repo is an ordinary, independent git repo — `cd` in, branch, commit, and push as usual.
Nothing in this superproject needs updating afterward (that's the point of dropping submodules):

```bash
cd DopplerEffect
git switch -c my-change
# ...edit, commit, push...
```

Shared conventions (tech stack, bootstrap chain, CI wiring) are documented in the org
[`.github/CLAUDE.md`](https://github.com/OpenPhysics/.github/blob/main/CLAUDE.md);
accessibility in [`Baton/ACCESSIBILITY.md`](https://github.com/OpenPhysics/Baton/blob/main/ACCESSIBILITY.md);
fleet conventions in [`Baton/CONVENTIONS.md`](https://github.com/OpenPhysics/Baton/blob/main/CONVENTIONS.md).
