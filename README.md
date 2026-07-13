[![ABAP_STANDARD](https://github.com/abap2UI5-addons/se16n/actions/workflows/ABAP_STANDARD.yaml/badge.svg)](https://github.com/abap2UI5-addons/se16n/actions/workflows/ABAP_STANDARD.yaml)
[![ABAP_CLOUD](https://github.com/abap2UI5-addons/se16n/actions/workflows/ABAP_CLOUD.yaml/badge.svg)](https://github.com/abap2UI5-addons/se16n/actions/workflows/ABAP_CLOUD.yaml)
[![ABAP_702](https://github.com/abap2UI5-addons/se16n/actions/workflows/ABAP_702.yaml/badge.svg)](https://github.com/abap2UI5-addons/se16n/actions/workflows/ABAP_702.yaml)
<br>
[![auto_cloud](https://github.com/abap2UI5-addons/se16n/actions/workflows/auto_cloud.yaml/badge.svg)](https://github.com/abap2UI5-addons/se16n/actions/workflows/auto_cloud.yaml)
[![auto_downport](https://github.com/abap2UI5-addons/se16n/actions/workflows/auto_downport.yaml/badge.svg)](https://github.com/abap2UI5-addons/se16n/actions/workflows/auto_downport.yaml)
<br>
[![renaming](https://github.com/abap2UI5-addons/se16n/actions/workflows/rename_test.yaml/badge.svg)](https://github.com/abap2UI5-addons/se16n/actions/workflows/rename_test.yaml)

# se16n
Browse, filter and edit table content in your browser – the classic SE16N, as an abap2UI5 app.

#### Key Features
* SE16N transaction in your browser

#### Compatibility
* S/4 Public Cloud and BTP ABAP Environment (ABAP for Cloud)
* S/4 Private Cloud or On-Premise (ABAP for Cloud, Standard ABAP)
* SAP NetWeaver AS ABAP 7.50 or higher (Standard ABAP)

#### Security
This is a developer tool. It reads the contents of any table the user names, without an authorization check of its own — access is therefore only bounded by whatever restrictions exist on the underlying handler/service. Before using it beyond a development system, add your own authorization checks (e.g. `AUTHORITY-CHECK` on `S_TABU_DIS`/`S_TABU_NAM`) and restrict who may run the app.

#### Dependencies
* [abap2UI5](https://github.com/abap2UI5/abap2UI5)
* [layout-management](https://github.com/abap2UI5-addons/layout-management)
* [selection-screen](https://github.com/abap2UI5-addons/selection-screen)


#### Demo

###### Selection
<img width="600" alt="Selection screen" src="https://github.com/user-attachments/assets/903c6a3b-a4bb-4c52-85c7-c63cc680580a" />

###### View
<img width="600" alt="Table display" src="https://github.com/user-attachments/assets/43565e2b-0eab-47bc-a0ed-e822a476aeb4" />


#### Contribution & Support
Pull requests are welcome! Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated. If you encounter any issues, feel free to open an issue.
