---
layout: home

hero:
  name: "SE16N"
  text: "Browse and filter table content: the classic SE16N in the browser."
  image:
    src: /favicon.png
    alt: abap2UI5
  actions:
    - theme: brand
      text: Get started
      link: /guide
    - theme: alt
      text: GitHub
      link: https://github.com/abap2UI5-addons/se16n
    - theme: alt
      text: All addons
      link: https://abap2ui5-addons.github.io/

features:
  - title: "Table name input with select-options for all fields and saved variants"
  - title: "Choose Layout picks a layout saved earlier for the table"
  - title: "Result table of at most 100 rows; layout popup for columns, order, labels, sorting"
  - title: "Runs on ABAP Cloud and on premise"
  - title: "Compact example of how range-filter and layout-management fit together"
---

## What it does

se16n is an abap2UI5 app that shows the content of any table: enter a table name, narrow the selection with select-options for every field, pick a saved layout and see the result as a table whose columns you can rearrange and save as a layout. It runs on ABAP Cloud, where there is no SE16N, as well as on premise. The selection comes from the range-filter addon and the result table and its layouts from layout-management. It is a developer tool without authorization checks of its own, so add your own before using it beyond a development system.

## Requirements

- abap2UI5
- abap2UI5-addons/layout-management
- abap2UI5-addons/range-filter
- ABAP Cloud (S/4 Public Cloud, BTP ABAP Environment), S/4 Private Cloud or On-Premise, or NetWeaver 7.50 or higher
- No 7.02 downport

## Installation

With [abapGit](https://abapgit.org), from [the repository](https://github.com/abap2UI5-addons/se16n):

- Install with abapGit in this order: 1. abap2UI5, 2. layout-management, 3. range-filter, 4. this repository (branch main)
- Start with ?app_start=z2ui5_cl_se16_app_01
- Add authorization checks (e.g. S_TABU_DIS / S_TABU_NAM) before opening it to other users

The [Guide](/guide) has every step.

## A first app

```abap
?app_start=z2ui5_cl_se16_app_01
```

## Links

- [abap2UI5-addons/range-filter](https://github.com/abap2UI5-addons/range-filter)
- [abap2UI5-addons/layout-management](https://github.com/abap2UI5-addons/layout-management)
- [abap2UI5](https://github.com/abap2UI5/abap2UI5)
- [The repository](https://github.com/abap2UI5-addons/se16n) - issues and pull requests welcome
