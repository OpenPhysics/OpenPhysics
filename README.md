# OpenPhysics

Superproject (git submodule aggregator) for the [OpenPhysics](https://github.com/OpenPhysics)
organization. Cloning this repo with submodules gives you the whole org — every simulation, the
shared infrastructure, and the hardware/tooling libraries — checked out side by side in one
workspace, which is exactly the layout the Baton scripts expect.

## Clone

```bash
git clone --recurse-submodules git@github.com:OpenPhysics/OpenPhysics.git
cd OpenPhysics

# already cloned without --recurse-submodules?
git submodule update --init --recursive
```

Update every submodule to the latest commit its branch points at:

```bash
git submodule update --remote --merge
```

## Layout

Two infrastructure repos plus the member repos, all as submodules:

| Submodule | Type | Purpose |
|---|---|---|
| [`.github`](.github) | config | Org community-health defaults (license, contributing, code of conduct, security, issue/PR templates, org profile) **plus** shared AI-assistant guidance (`CLAUDE.md`, `skills/`). GitHub requires these in the special `.github` repo. |
| [`Baton`](Baton) | tool | Org **orchestration**: reusable CI/CD workflows, the cross-repo automation scripts, Dependabot templates, the machine-readable repo catalog (`structure/repos.json`), and the GitHub Pages landing page. |
| `TemplateSingleSim` | template | Canonical starting point — new sims are forked from it and start accessible by default. |
| `DopplerEffect`, `ElectricFieldOfDreams`, `LadyBug`, `LunarLander`, `MazeGame`, `MovingMan`, `OpticsLab`, `OscillationsAndChaos`, `QubitSketch`, `RadioWaves`, `Resonance`, `TheRamp`, `TrackLab`, `WaveComposer` | simulation | SceneryStack TypeScript simulations. |
| `jscd48`, `tscd48`, `pycd48` | hardware-interface | CD48 hardware libraries (the JS/TS ones use MIT, not the org AGPL default). |
| `pyro` | tool | Python tooling. |

> **`.github` vs `Baton`:** `.github` holds only what GitHub *must* serve from the special repo
> (community health + AI guidance). Everything operational — CI workflows, catalog, scripts,
> Pages — lives in `Baton`. Keep that split: don't add workflows to `.github` or community-health
> files to `Baton`.

`Baton/structure/repos.json` is the source of truth for what exists in the org. The compliance
audit, the Pages landing page, and every `Baton/scripts/*` tool read it. The scripts default
`OPENPHYSICS_WORKSPACE` to this superproject root, so they find sibling submodules with no extra
configuration.

## Common tasks

```bash
# List the simulation repos
Baton/scripts/parse-repos.sh names --simulation

# Audit README + CI compliance for one sim
Baton/scripts/check-repo-compliance.sh DopplerEffect

# Preview a change across all sims (dry-run, opens nothing)
Baton/scripts/fleet-exec.sh --simulation -- npm pkg set dependencies.scenerystack=^3.1.0
```

See [`Baton/README.md`](Baton/README.md) for orchestration and [`Baton/scripts/README.md`](Baton/scripts/README.md)
for the full tooling reference.

## Working in a submodule

Each submodule is an independent git repo with its own remote and branch. Commit and push inside
the submodule first, then commit the updated pointer (gitlink) in this superproject:

```bash
cd DopplerEffect
git switch -c my-change          # branch, don't commit on a detached HEAD
# ...edit, commit, push...
cd ..
git add DopplerEffect            # records the new submodule SHA
git commit -m "chore: bump DopplerEffect pointer"
```

Shared conventions (tech stack, bootstrap chain, CI wiring) are documented in the org
[`.github/CLAUDE.md`](.github/CLAUDE.md); accessibility in [`ACCESSIBILITY.md`](ACCESSIBILITY.md).
