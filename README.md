[![Build Status](https://travis-ci.org/nightingaleproject/nightingale.svg?branch=master)](https://travis-ci.org/nightingaleproject/nightingale)

## Nightingale EDRS Prototype

Nightingale is a prototype electronic death registration system (EDRS), built to both demonstrate basic EDRS capabilities and act as a foundation for exploring next generation EDRS concepts. This prototype represents a work-in-progress, and is expected to change and grow over time in response to feedback from subject matter experts and users. Nightingale ERDS currently supports the following functionality at various degrees of maturity:

* User roles for funeral directors, medical certifiers, registrars, and administrators
* Death record data entry
* Validation of death record data using VIEWS
* Basic support for configurable, flexible workflows, such as
  * Determining who can initiate a death record
  * Assignment of in-process death records to other system users
  * Token based login for medical certifiers who are infrequent system users
* Workflow and Death record versioning
* Support for structured data entry, minimizing opportunities for user error
* Auditing of user actions
* Export of records in IJE format
* Basic issuance and archival of death certificates
* Basic reports on system usage patterns
* Basic reports on collected mortality data

### Installation and Setup for Development or Testing

Nightingale EDRS is a Ruby on Rails application that uses the PostgreSQL database for data storage.

For information on how to deploy Nightingale as a Docker container, see [CONTAINERDEPLOY.md](CONTAINERDEPLOY.md).

#### Prerequisites

To work with the application, you will need to install some prerequisites:

* [Ruby](https://www.ruby-lang.org/)
* [Bundler](http://bundler.io/)
* [Postgres](http://www.postgresql.org/)

Once the prerequisites are available, Nightingale can be installed and demonstration data can be loaded.

#### Setup

* Retrieve the application source code

    `git clone https://github.com/nightingaleproject/nightingale.git`

* Change into the new directory

    `cd nightingale`

* Install ruby gem dependencies

    `bundle install`

* Create the database

    `bundle exec rake db:drop db:create db:migrate db:setup RAILS_ENV=development`

* Set up system with demonstration data

    `bundle exec rake nightingale:demo:setup`

  * This will initialize Nightingale with demonstration data, such as:
    * Demo user accounts (all with a password of 123456):
      * Two funeral director users (fd1@example.com, fd2@example.com)
      * Two physician users (doc1@example.com, doc2@example.com)
      * Two medical examiner users (me1@example.com, me2@example.com)
      * Two registrar users (reg1@example.com, reg2@example.com)
      * An administrator user (admin@example.com)
    * Two demo workflows:
      * A simple workflow where a funeral director initiates a record
      * A simple workflow where a physician initiates a record
    * U.S. geographical data, used for structured data input

#### Tasks

* Manage user accounts

  * Create a user

      `bundle exec rake nightingale:users:create EMAIL=<email_address> PASS=<password>`

  * List all currently registered users (and their roles)

      `bundle exec rake nightingale:users:list`

  * Delete a user

      `bundle exec rake nightingale:users:delete EMAIL=<email_address>`

  * Grant a user admin privileges

      `bundle exec rake nightingale:users:grant_admin EMAIL=<email_address>`

  * Revoke admin privileges from a user

      `bundle exec rake nightingale:users:revoke_admin EMAIL=<email_address>`

  * Add a role to a user

      `bundle exec rake nightingale:users:add_role EMAIL=<email_address> ROLE=<role>`

* Update system workflows

    `bundle exec rake nightingale:workflows:build`

* Run tests

    `bundle exec rake db:drop db:create db:migrate RAILS_ENV=test` (creates test DB, needed first time only)
    `bundle exec rake test`

* Run the application server

    `bundle exec rails server`

    The server will be running at http://localhost:3000/

### Version History

This project adheres to [Semantic Versioning](http://semver.org/).

Releases are documented in the [CHANGELOG](https://github.com/nightingaleproject/nightingale/blob/master/CHANGELOG.md).

### License

Copyright 2017, 2018, 2019 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

### Contact Information

For questions or comments about Nightingale EDRS, please send email to

    cdc-nvss-feedback-list@lists.mitre.org
