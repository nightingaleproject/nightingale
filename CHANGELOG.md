## Change Log

### v0.4.0 - 2017-06-12

* Integrated the react-rails framework for front-end user interaction
* Implemented flexbox layouts in the UI for compatibility with more device form factors
* Implemented JSON configurable workflows
* Added versioning support for workflows and their corresponding death records
* Rewrote database death record model and workflow to be more dynamic
* Improved user workflows related to partial and incomplete data
* Exposed illustration API to allow demonstration of EHR integration concepts
* Integrated Bootstrap 4 for UI styling
* Updated Rails version

### v0.3.0 - 2017-05-01

* Added check for unsaved changes before navigation
* Added support for notification emails

### v0.2.0 - 2017-04-03

* Redesigned and refactored user dashboards
  * New and revised graphs
  * Viewing and tracking of transferred records
  * Soft deletion of death records (keeping historical record)
* Support for more flexible workflow customizations
* Refined data validation to allow entry of partial data
* Reworked retrieval of geographic data from backend for increased efficiency
* Added basic API for initial testing of FHIR client for EHR integration workflow

### v0.1.0 - 2017-03-01

* User roles for funeral directors, medical certifiers, registrars, and administrators
* Death record data entry
* Basic support for configurable, flexible workflows, such as
  * Determining who can initiate a death record
  * Assignment of in-process death records to other system users
  * Token based login for medical certifiers who are infrequent system users
* Support for structured data entry, minimizing opportunities for user error
* Auditing of user actions
* Basic reports on system usage patterns
* Configurable "supplemental questions", allowing ad-hoc support for specific data gathering needs such as collecting information related to specific natural disasters
