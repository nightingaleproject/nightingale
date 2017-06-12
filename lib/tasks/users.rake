# Rake tasks for configuring Nightingale user accounts.
namespace :nightingale do
  namespace :users do
    desc %(Creates a new user.

    You must identify an email address and password:

    $ rake nightingale:users:create EMAIL=### PASS=###)
    task create: :environment do
      user = User.create!(email: ENV['EMAIL'], password: ENV['PASS'])
      if user
        user.confirm
        puts 'The user was created successfully.'
      else
        puts 'The user was not created!'
      end
    end

    desc %(Deletes a user.

    You must identify an email address:

    $ rake nightingale:users:delete EMAIL=###)
    task delete: :environment do
      user = User.find_by(email: ENV['EMAIL'])
      if !user.nil? && user.destroy
        puts 'The user was deleted successfully.'
      elsif !user.nil?
        puts 'The user was not deleted!'
      else
        puts 'User not found!'
      end
    end

    desc %(Prints a list of users by their Email addresses and roles.

    $ rake nightingale:users:list)
    task list: :environment do
      users = User.all
      users.each do |user|
        puts 'Email: ' + user.email + ', Roles: ' + user.roles
      end
    end

    desc %(Grants a user admin privileges.

    You must identify an email address:

    $ rake nightingale:users:grant_admin EMAIL=###)
    task grant_admin: :environment do
      user = User.find_by(email: ENV['EMAIL'])
      if !user.nil?
        user.grant_admin unless user.admin?
        if user.admin?
          puts 'User was granted admin privileges.'
        else
          puts 'User was not granted admin privileges!'
        end
      else
        puts 'User not found!'
      end
    end

    desc %(Revokes admin privileges from a user.

    You must identify an email address:

    $ rake nightingale:users:revoke_admin EMAIL=###)
    task revoke_admin: :environment do
      user = User.find_by(email: ENV['EMAIL'])
      if !user.nil?
        user.revoke_admin if user.admin?
        if user.admin?
          puts 'Admin privileges not revoked for user!'
        else
          puts 'Admin privileges revoked for user.'
        end
      else
        puts 'User not found!'
      end
    end

    desc %(Add a role to user.

    You must identify an email address and role:

    $ rake nightingale:users:add_role EMAIL=### ROLE=###)
    task add_role: :environment do
      user = User.find_by(email: ENV['EMAIL'])
      if !user.nil?
        user.add_role ENV['ROLE']
        if user.has_role? ENV['ROLE']
          puts 'Role was added to User successfully'
        else
          puts 'Role was not added to the User'
        end
      else
        puts 'User not found!'
      end
    end
  end
end
