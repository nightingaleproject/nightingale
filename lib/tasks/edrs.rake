namespace :edrs do
  namespace :demo do
    desc %(Creates demo user accounts.

    $ rake edrs:demo:setup)
    task setup: :environment do
      user = User.create!(email: 'fd@test.com', password: '123456')
      if user
        user.confirm
        puts 'The fd was created successfully'
        user.add_role 'funeral_director'
      end
      user1 = User.create!(email: 'doc@test.com', password: '123456')
      if user1
        user1.confirm
        puts 'The doc was created successfully'
        user1.add_role 'physician'
      end
      user2 = User.create!(email: 'reg@test.com', password: '123456')
      if user2
        user2.confirm
        puts 'The registrar was created successfully'
        user2.add_role 'registrar'
      end
    end
  end

  namespace :users do
    desc %(Creates a new user.

    You must identify an email address and password:

    $ rake edrs:users:create EMAIL=### PASS=###)
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

    $ rake edrs:users:delete EMAIL=###)
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

    desc %(Prints a list of users by their Email addresses and roles.)
    task list: :environment do
      users = User.all
      users.each do |user|
        user.roles.each do |role|
          puts 'Email: ' + user.email + ', Role: ' + role.name
        end
      end
    end

    desc %(Grants a user admin privileges.

    You must identify an email address:

    $ rake edrs:users:grant_admin EMAIL=###)
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

    $ rake edrs:users:revoke_admin EMAIL=###)
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

    $ rake edrs:users:add_role EMAIL=### ROLE=###)
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
