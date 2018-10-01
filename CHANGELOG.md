## Change Log

### v0.11.0 - 2018-10-01

* Upgraded Boostrap version

### v0.10.0 - 2018-09-06

* Added ability for admins to export (and download) individual records in IJE and FHIR (XML and JSON) format
* Changed target Ruby version to 2.4.4
* Various dependency updates

### v0.9.0 - 2018-05-10

* Updated Demo workflow steps to better reflect 2003 certificate of death
* Tweaked IJE exporting to reflect workflow changes
* Updated Death on FHIR producing/consuming to support latest profiles

### v0.8.0 - 2018-03-01

* Implemented FHIR Importing and Exporting
* Made adjustments to the demo workflows to make them properly in line with the 2003 certificate of death
* Updated Nokogiri to 1.8.2 to address vulnerability

### v0.7.0 - 2017-12-07

* Added Docker containerization configuration and instructions
* Updated administration rake tasks to better reflect Devise configuration
* Adjusted how the auditing tool does searching
* Adjusted level of activity logging for auditing
* Updated some project configurations and structure for production deployments

### v0.6.0 - 2017-11-01

* Added unit tests
* Minor bug fixes

### v0.5.0 - 2017-10-02

* Added VIEWS validation for death records
* Implemented ability to abandon records
* Implemented email notifications for normal users
* Added UI notifications to the dashboard view
* Added Physician attestation dialog before a record is sent for registration
* Added analysis reporting tool for administrative users
* Implemented IJE exporting functionality
* Implemented issuance functionality for death records
* Implemented pagination for dashboard view
* Added travis config for continuous integration
* Added OAuth2 support
* Added Brakeman and Bundle Audit security checks
* Added RSpec, Capybara, and Selenium for front end functional testing
* Implemented Selenium tests for all major front end features
* Added test fixtures derived from demo workflow database snapshot
* Revamped the My Account page
* Implemented pagination for the Audit logging view for administrative users

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
