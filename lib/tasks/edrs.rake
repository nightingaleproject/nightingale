namespace :edrs do
  namespace :demo do
    desc %(Handy task to configure the database for demo use.

    Calls:
      - edrs:demo:create_users
      - edrs:demo:load_funeral_facilities

    $ rake edrs:demo:setup)
    task setup: :environment do
      Rake::Task['edrs:demo:create_users'].invoke
      Rake::Task['edrs:demo:load_funeral_facilities'].invoke
    end

    desc %(Creates demo user accounts.

    $ rake edrs:demo:create_users)
    task create_users: :environment do
      # Generate system users
      user = User.create!(email: 'fd@test.com', password: '123456', first_name: 'Example', last_name: 'FD', telephone: '000-876-5309')
      if user
        user.confirm
        puts user.email + ' was created successfully'
        user.add_role 'funeral_director'
      end
      user = User.create!(email: 'fd2@test.com', password: '123456', first_name: 'Example', last_name: 'FD', telephone: '000-876-5310')
      if user
        user.confirm
        puts user.email + ' was created successfully'
        user.add_role 'funeral_director'
      end
      user = User.create!(email: 'doc@test.com', password: '123456', first_name: 'Example', last_name: 'Physician', telephone: '111-876-5309')
      if user
        user.confirm
        puts user.email + ' was created successfully'
        user.add_role 'physician'
      end
      user = User.create!(email: 'doc2@test.com', password: '123456', first_name: 'Example', last_name: 'Physician', telephone: '111-876-5310')
      if user
        user.confirm
        puts user.email + ' was created successfully'
        user.add_role 'physician'
      end
      user = User.create!(email: 'reg@test.com', password: '123456', first_name: 'Example', last_name: 'Registrar', telephone: '222-876-5309')
      if user
        user.confirm
        puts user.email + ' was created successfully'
        user.add_role 'registrar'
      end
      user = User.create!(email: 'admin@test.com', password: '123456', first_name: 'Example', last_name: 'Admin', telephone: '333-876-5310')
      if user
        user.confirm
        puts user.email + ' was created successfully'
        user.grant_admin unless user.admin?
      end
    end

    desc %(Loads YML fixture file containing funeral director information.

    Fixture files are located at:
      - test/fixtures/funeral_director.yml

    $ rake edrs:demo:load_funeral_facilities)
    task load_funeral_facilities: :environment do
      ENV['FIXTURES'] = 'funeral_facilities'
      Rake::Task['db:fixtures:load'].invoke
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
        puts 'Email: ' + user.email + ', Roles: ' + user.roles
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
