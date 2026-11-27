# AGENTS.md — AI Assistant Guide for abap2UI5 se16n

> This file follows the cross-tool AGENTS.md convention and is the single
> agent instruction file of this repository — `CLAUDE.md` only points here.

## Project Overview

An SE16N-like data browser in the browser, built with
[abap2UI5](https://github.com/abap2UI5/abap2UI5).

**Language:** English — all code, comments, commit messages, PRs, issues and
documentation must be in English.

## Package Structure

| Package | Content |
|---|---|
| `src/z2ui5_cl_se16_app_01` / `_02` | Selection screen and data view |
| `src/z2ui5_cl_se16_context`, `src/z2ui5_cx_se16_error` | Vendored utility copies — **see below** |

## The Utility Copy Principle

`z2ui5_cl_se16_context` is a **renamed copy** of `zabaputil_cl_util_context`
from the [abap-util](https://github.com/abap-util/abap-util) **master catalog**,
**trimmed to the methods this addon uses** (`rtti_create_tab_by_name`,
`filter_get_sql_where`) plus the private helpers, types and constants those
need. `z2ui5_cx_se16_error` is the master's `zabaputil_cx_util_error`, renamed
and copied as-is. This keeps the install dependency-free (abapGit has no
dependency management).

1. **Nothing from the core's frozen `src/99/01`.** `z2ui5_cl_util*` and
   `z2ui5_cx_util_error` are kept in abap2UI5 for compatibility only; the app
   calls `z2ui5_cl_se16_context=>…`, every utility exception is
   `z2ui5_cx_se16_error`.
2. **Method-level trimming** applies to the context class only, and keeps
   every helper a kept method needs.
3. **New methods are added locally.** If the method already exists in
   abap-util, copy it from there (with its helpers) instead of re-implementing
   it. Do not add a dependency on another project's copy.
4. **Periodic AI sync-back:** abap-util compares all consumers every few weeks
   and merges what was added or fixed here back into the master.

`.github/abap-util.json` names the copies and their masters for abap-util's
`sync-check`: with abap-util checked out next to this repository,
`node ../abap-util/.github/scripts/sync-check.mjs --consumer . --report`
lists every method whose body or declaration differs from the master and
every method only this copy has. `commit` is the abap-util commit the copies
match: run the script without `--report` at that commit and it fails on any
difference that is not named under `settled` or `own`. After a refresh, set
`commit` to the commit the copies were taken from.

## Dependencies

Installed alongside via abapGit; declared in the abaplint configs:

* [abap2UI5](https://github.com/abap2UI5/abap2UI5)
* [layout-management](https://github.com/abap2UI5-addons/layout-management)
* [range-filter](https://github.com/abap2UI5-addons/range-filter)

## Security

This is a developer tool. It reads the contents of any table the user names,
without an authorization check of its own. Before using it beyond a development
system, add your own `AUTHORITY-CHECK`s (e.g. on `S_TABU_DIS`/`S_TABU_NAM`) and
restrict who may run the app. The result is capped at 100 rows.

**Shipping without an authorization check is a deliberate decision of the
maintainer (2026-11-17), stated in the README - do not add one and do not
report its absence as a finding.**

## Coding Style

Follows the abap2UI5 core conventions (see its
[AGENTS.md](https://github.com/abap2UI5/abap2UI5/blob/main/AGENTS.md)): Clean
ABAP with Hungarian prefixes, backtick string literals. Do not swallow errors
with an empty `CATCH` — surface them to the user.

## Validation

Run `npm run check` before considering changes complete: it runs the same
abaplint, abap2UI5-linter and rename steps as CI, and all of them must pass.
CI comes from the shared CI template of abap2UI5-addons (reusable workflows in
[rap-ext](https://github.com/abap2UI5-addons/rap-ext/blob/main/.github/ci/README.md),
pinned by commit in the `uses:` lines and moved by `bump-deps`):

* `ci` - one workflow, one job per check: abaplint against Standard ABAP
  (`abaplint.jsonc`) and ABAP Cloud (`.github/abaplint/abap_cloud.jsonc`),
  `abap2ui5lint` (the app classes and their views, `abap2ui5lint.jsonc`),
  `unit` - the ABAP Unit tests on abap2UI5's transpiled Node runtime, the way
  abap2UI5 tests itself: `npm run unit` (`.github/scripts/unit.mjs`) copies
  the packages into a checkout of abap2UI5's `main` (abap2UI5-ext,
  layout-management and range-filter beside it), downports, transpiles and
  runs the tests of this repository's classes - and `rename`, the
  namespace-rename check (`npm run rename`, `.github/scripts/rename.mjs`)
* `build-rename` — manual workflow that pushes a namespace-renamed branch
  `rename_<name>` for a parallel install
* `ci-702` — writes the downported `702` branch on every push to `main`
  (`npm run auto_downport` against `.github/abaplint/abap_702.jsonc`) and
  lints it. Never commit to `702` by hand.

The sibling addons (layout-management, range-filter) are resolved at the
commit `.github/deps.json` pins, in CI and in `npm run unit`; `bump-deps`
moves the pins monthly, and the weekly `ci` run checks their tips (the
canary). A local `npm run check` still clones their `main`. The 702 config
gives them folders of their own (`/layout-management-702`): the template
fills `/layout-management` beside it with the pinned commit.

All `.abap`/`.xml`/config files are LF-only (`.gitattributes` enforces it).

## Namespace rename

`npm run rename` (CI: the `rename` job of `ci`) and the manual `build-rename` workflow
are abap2UI5's namespace rename for this addon - `.github/scripts/rename.mjs`,
the same file in every addon that has one. Every `z2ui5_` object becomes
`<name>_...`, for a customer name such as `ZMYUI5` or a registered namespace
such as `/CA2UI5/` (at most 10 characters), and so does every reference to
abap2UI5 and to the addons this one builds on: the branch `rename_<name>` runs
on an abap2UI5 renamed with the same name by its own `build-rename`. What
follows from it:

- Every object name has at most 25 characters (a transparent table
  11, an ICF node 10) - 30 minus what the longest new name adds.
- No literal names a `z2ui5_` object: the rename rewrites references, never a
  literal. Derive the name - from a typed reference, or behind the prefix of
  the class's own name.
- A change that spans several repositories: `RENAME_DEPS_FROM=<dir> npm run
  rename` takes the dependencies from the clones in `<dir>`.
