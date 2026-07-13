# AGENTS.md — AI Assistant Guide for abap2UI5 se16n

> This file follows the cross-tool AGENTS.md convention and is the single
> agent instruction file of this repository — Claude Code reads `AGENTS.md`
> natively, there is no separate `CLAUDE.md`.

## Project Overview

An SE16N-like data browser in the browser, built with
[abap2UI5](https://github.com/abap2UI5/abap2UI5).

**Language:** English — all code, comments, commit messages, PRs, issues and
documentation must be in English.

## Package Structure

| Package | Content |
|---|---|
| `src/z2ui5_cl_tm_se16_01` / `_02` | Selection screen and data view |
| `src/z2ui5_cl_se16_context` | Vendored utility copy — **see below** |

## The Utility Copy Principle

`z2ui5_cl_se16_context` is a **trimmed, renamed copy** of the abap2UI5 utility
class (`z2ui5_cl_util` in the core), carrying only the two methods this addon
uses (`rtti_create_tab_by_name`, `filter_get_sql_where`) plus the private helper
and filter types those need. The app calls `z2ui5_cl_se16_context=>…`, never
`z2ui5_cl_util=>…` directly. This keeps the install dependency-free (abapGit has
no dependency management). The core and the other addons use the same pattern.
When a new utility method is needed, copy it from the core utility class (with
its private helpers) into the context copy rather than adding a dependency.

## Dependencies

Installed alongside via abapGit; declared in the abaplint configs:

* [abap2UI5](https://github.com/abap2UI5/abap2UI5)
* [layout-management](https://github.com/abap2UI5-addons/layout-management)
* [selection-screen](https://github.com/abap2UI5-addons/selection-screen)

## Security

This is a developer tool. It reads the contents of any table the user names,
without an authorization check of its own. Before using it beyond a development
system, add your own `AUTHORITY-CHECK`s (e.g. on `S_TABU_DIS`/`S_TABU_NAM`) and
restrict who may run the app. The result is capped at 100 rows.

## Coding Style

Follows the abap2UI5 core conventions (see its
[AGENTS.md](https://github.com/abap2UI5/abap2UI5/blob/main/AGENTS.md)): Clean
ABAP with Hungarian prefixes, backtick string literals. Do not swallow errors
with an empty `CATCH` — surface them to the user.

## Validation

Run `npx abaplint` before considering changes complete (config `abaplint.jsonc`,
0 issues expected). CI:

* `ABAP_STANDARD` / `ABAP_CLOUD` — lint against Standard ABAP and ABAP Cloud
* `renaming` (`rename_test.yaml`) — namespace-rename check
* `build_rename` — manual workflow that pushes a namespace-renamed branch
  `rename_<name>` for a parallel install

There is no 702 downport: the selection-screen dependency has no `702` branch.
All `.abap`/`.xml`/config files are LF-only (`.gitattributes` enforces it).
