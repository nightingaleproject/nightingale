## Change Log

### v0.4 - 2017-06-05
* Nightingale now utilizes the react-rails framework for front-end user interaction
* UI now leverages flexbox layouts for compatibility with more device form factors

### v0.3 - 2017-05-15
* Implemented JSON configurable workflows
* Workflows and their corresponding death records are now versioned

### v0.2 - 2017-04-03

* Redesigned and refactored user dashboards
  * New and revised graphs
  * Viewing and tracking of transferred records
  * Soft deletion of death records (keeping historical record)
* Support for more flexible workflow customizations
* Refined data validation to allow entry of partial data
* Reworked retrieval of geographic data from backend for increased efficiency
* Added basic API for initial testing of FHIR client for EHR integration workflow

### v0.1 - 2017-03-01

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
