# Yapfast

- Run every cargo command in the dev shell, with the `fast` profile:
  `nix develop path:./nix --command cargo build --profile fast`.
- While working, build and test only what changed, such as
  `cargo test --profile fast -p yapfast-core history`; incremental builds take
  seconds. Run `scripts/check --fast` once, before the last commit of a piece
  of work, not before each commit. It enters the dev shell itself and covers
  Discord-only, Matrix-only and headless builds; it takes about 40 s after
  a Rust edit and 4 minutes after a `.slint` edit, and prints each step's
  time. Its steps run one after another: each compile of the UI crate takes
  6–8 GiB of memory, and running them together ran the machine out of it.
- In a new worktree, run `scripts/warm-worktree` before building. It copies
  the main checkout's build, so the first check compiles only the crates in
  the repository, about 3.5 minutes.
- An edit under `vendor/i-slint-*` recompiles Slint and the UI crate, 2–3
  minutes each time; settle such a patch in as few builds as possible.
- See the app: `scripts/ui-session` (private display, screenshots, input; run
  it with `--help`). Discord runs only against `testing/fake_discord.ts`.
  For a run of `.slint` edits, `start --live` shows each save in under a
  second instead of rebuilding the UI crate; the Edit tool's saves go
  unnoticed until you `touch` the file.
- Measure and profile with the `measure` profile, not `fast`: `fast` leaves
  the Slint interface unoptimized.
- Discord's API, as its own apps use it: https://docs.discord.food. Look up
  an endpoint, payload or gateway event there before adding or changing one,
  and give the fake the same shape.
- Discord service tests: `scripts/test-fake-discord`. Matrix and LiveKit:
  `scripts/test-stack up`.
- How a UI change flows from `ui/*.slint` to `application/`:
  `docs/architecture.md`. Shells, logging (`YAPFAST_LOG`, not `RUST_LOG`) and
  dependency sources: `docs/building.md`.
- Memory is a product goal. Keep every change lean without being asked, and
  check the code it runs through as well: share data held in two places
  (`Arc`, a borrow), make work that runs on every event or frame touch only
  what changed, and stream data to a file or socket as it's made. Fix a
  needless copy you find on that path, or report it. Targets, and how to
  measure: `docs/measurements/README.md`. A commit that saves memory gives
  the numbers it measured.
- Start new branches from `upstream/main` after `git fetch upstream`.
- Every feature or fix is its own branch from `upstream/main`: `pr/*` for what
  goes upstream, `local/*` for what stays in the fork (CI, packaging, this
  file). Never commit to `dev`: `scripts/rebuild-dev` resets it to
  `upstream/main` and merges those branches again, so a commit made on `dev`
  is lost. The goal is a `dev` of the newest `upstream/main` with all those
  branches merged in, published as a working Flatpak.
