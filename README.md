# README

Electronic Death Registration System (EDRS) app built using Ruby on Rails

# Rake tasks:

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
 
Add a role to a user:
```
bundle exec rake edrs:users:add_role EMAIL=<email_address> ROLE=<role>
```
