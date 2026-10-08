# se16n

[![abap2UI5-addons](https://img.shields.io/badge/abap2UI5--addons-app-1873b4)](https://github.com/abap2UI5-addons)
[![ABAP](https://img.shields.io/badge/ABAP-Cloud%20%7C%20Standard%20%E2%89%A5%207.50-blue)](#installation)
[![abap2UI5](https://img.shields.io/badge/requires-abap2UI5-blue)](https://github.com/abap2UI5/abap2UI5)
[![layout-management](https://img.shields.io/badge/requires-layout--management-blue)](https://github.com/abap2UI5-addons/layout-management)
[![selection-screen](https://img.shields.io/badge/requires-selection--screen-blue)](https://github.com/abap2UI5-addons/selection-screen)
[![License](https://img.shields.io/github/license/abap2UI5-addons/se16n)](LICENSE)
<br>
[![ABAP Cloud](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/se16n/abap-cloud.yaml?branch=main&label=ABAP%20Cloud)](https://github.com/abap2UI5-addons/se16n/actions/workflows/abap-cloud.yaml)
[![ABAP Standard](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/se16n/abap-standard.yaml?branch=main&label=ABAP%20Standard)](https://github.com/abap2UI5-addons/se16n/actions/workflows/abap-standard.yaml)
[![rename](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/se16n/check-rename.yaml?branch=main&label=rename)](https://github.com/abap2UI5-addons/se16n/actions/workflows/check-rename.yaml)
[![check-abap2UI5](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fabap2UI5-addons%2Fse16n%2Fbadges%2Fcheck-abap2ui5.json)](https://github.com/abap2UI5-addons/se16n/actions/workflows/check-abap2ui5.yaml)
[![abap2UI5](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fabap2UI5-addons%2Fse16n%2Fbadges%2Fabap2ui5.json)](https://github.com/abap2UI5-addons/se16n/actions/workflows/check-abap2ui5.yaml)

**Browse and filter table content in your browser - the classic SE16N, as an abap2UI5 app.**
Enter a table name, narrow the selection with select-options for every field,
pick a saved layout and see the result as a table whose columns you can
rearrange and save as a layout. It runs on ABAP Cloud, where there is no
SE16N, as well as on premise. A tool for developers and consultants.

> Part of [abap2UI5-addons](https://github.com/abap2UI5-addons) - addons and apps for [abap2UI5](https://github.com/abap2UI5/abap2UI5), installed with [abapGit](https://abapgit.org).

## Why

Looking into a table is one of the most common things a developer does - and
on ABAP Cloud there is no SAP GUI and no SE16N to do it. se16n gives you the
same quick look as a browser app.

It is also a compact example of how the addons fit together: the selection
comes from [selection-screen](https://github.com/abap2UI5-addons/selection-screen),
the result table and its layouts from
[layout-management](https://github.com/abap2UI5-addons/layout-management).

## Installation

**Requirements**

- ABAP Cloud (S/4 Public Cloud, BTP ABAP Environment), S/4 Private Cloud or
  On-Premise, or SAP NetWeaver AS ABAP 7.50 or higher
- [abap2UI5](https://github.com/abap2UI5/abap2UI5)
- [abap2UI5-addons/layout-management](https://github.com/abap2UI5-addons/layout-management) -
  the result table and its layouts
- [abap2UI5-addons/selection-screen](https://github.com/abap2UI5-addons/selection-screen) -
  the select-options and their variants

**Steps** - with [abapGit](https://abapgit.org), in this order:

1. [abap2UI5](https://github.com/abap2UI5/abap2UI5)
2. [abap2UI5-addons/layout-management](https://github.com/abap2UI5-addons/layout-management)
3. [abap2UI5-addons/selection-screen](https://github.com/abap2UI5-addons/selection-screen)
4. this repository (branch `main`)

There is no 7.02 downport: selection-screen has no `702` branch.

**Start** - run it like any abap2UI5 app: `?app_start=z2ui5_cl_tm_se16_01`.
Before you open it to other users, read [Security](#security).

## Usage

1. **Table** - enter the table name and press **Load**. The select-options for
   all its fields appear below; variants can be saved and loaded there.
2. **Layout** (optional) - **Choose Layout** picks a layout saved earlier for
   this table.
3. **GO** - shows the content, at most 100 rows. The settings button of the
   table opens the layout popup: columns, order, labels, sorting - saved per
   table. **Refresh** reads the data again.

| Class | Purpose |
|---|---|
| `z2ui5_cl_tm_se16_01` | Start app: table name, selection, layout |
| `z2ui5_cl_tm_se16_02` | Result list |
| `z2ui5_cl_se16_context` | Vendored copy of the two abap2UI5 utility methods the app uses |

## Features

* SE16N transaction in your browser

## Demo

### Selection
<img width="600" alt="Selection screen" src="https://github.com/user-attachments/assets/903c6a3b-a4bb-4c52-85c7-c63cc680580a" />

### View
<img width="600" alt="Table display" src="https://github.com/user-attachments/assets/43565e2b-0eab-47bc-a0ed-e822a476aeb4" />

## Security

This is a developer tool. It reads the contents of any table the user names, without an authorization check of its own — access is therefore only bounded by whatever restrictions exist on the underlying handler/service. Before using it beyond a development system, add your own authorization checks (e.g. `AUTHORITY-CHECK` on `S_TABU_DIS`/`S_TABU_NAM`) and restrict who may run the app.

## Development

```bash
npm ci
npm run check           # all gates below, as in CI
npm run lint            # abaplint, Standard ABAP (v750)
npm run check:cloud     # abaplint, ABAP Cloud
npm run check:abap2ui5  # abap2UI5-linter over apps and views
npm run rename          # namespace rename check
```

## Contributing

Issues and pull requests are welcome - whether you're fixing bugs, adding new
functionality, or improving documentation. Read
[CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

MIT - see [LICENSE](LICENSE).
