Nightingale
===========

Electronic Death Registration System (EDRS) app built using Ruby on Rails

Setup (for demo mode):
----------------------

```

        bundle exec rake db:drop
        bundle exec rake db:create
        bundle exec rake db:migrate
        bundle exec rake db:setup
        bundle exec rake edrs:demo:setup

```

This will create (all with the password "123456"):
- A funeral director user (fd@test.com)
- A physician user (doc@test.com)
- A registrar user (reg@test.com)

Rake tasks:
-----------

To create a user:
```
bundle exec rake edrs:users:create EMAIL=<email_address> PASS=<password>
```
 
To list all currently registered users (and their roles):
```
bundle exec rake edrs:users:list
```
 
To delete a user:
```
bundle exec rake edrs:users:delete EMAIL=<email_address>
```

To grant a user admin privileges:
```
bundle exec rake edrs:users:grant_admin EMAIL=<email_address>
```

To revoke admin privileges from a user:
```
bundle exec rake edrs:users:revoke_admin EMAIL=<email_address>
```
 
Add a role to a user:
```
bundle exec rake edrs:users:add_role EMAIL=<email_address> ROLE=<role>
```
