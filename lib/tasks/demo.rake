require 'csv'
require 'creek'
import 'lib/tasks/demoLoadData.rake'

# Rake tasks for setting up Nightingale for demo use.
namespace :nightingale do
  namespace :demo do
    desc %(Handy task to configure the database for demo use.

    Calls:
      - nightingale:workflows:build
      - nightingale:demo:create_demo_users
      - nightingale:geography:load_fixtures

    $ rake nightingale:demo:setup)
    task setup: :environment do
      Rake::Task['nightingale:workflows:build'].invoke
      Rake::Task['nightingale:demo:create_demo_users'].invoke
      Rake::Task['nightingale:geography:load_fixtures'].invoke
    end

    desc %(Creates demo user accounts.

    $ rake nightingale:demo:create_demo_users)
    task create_demo_users: :environment do
      print 'Creating demo users... '
      user = User.create!(email: 'fd1@example.com', password: '123456', first_name: 'Example', last_name: 'FD', telephone: '000-000-0000')
      user.add_role 'funeral_director'
      user = User.create!(email: 'fd2@example.com', password: '123456', first_name: 'Example', last_name: 'FD', telephone: '000-000-0000')
      user.add_role 'funeral_director'
      user = User.create!(email: 'doc1@example.com', password: '123456', first_name: 'Example', last_name: 'Certifier', telephone: '000-000-0000')
      user.add_role 'physician'
      user = User.create!(email: 'doc2@example.com', password: '123456', first_name: 'Example', last_name: 'Physician', telephone: '000-000-0000')
      user.add_role 'physician'
      user = User.create!(email: 'me1@example.com', password: '123456', first_name: 'Example', last_name: 'ME', telephone: '000-000-0000')
      user.add_role 'medical_examiner'
      user = User.create!(email: 'me2@example.com', password: '123456', first_name: 'Example', last_name: 'ME', telephone: '000-000-0000')
      user.add_role 'medical_examiner'
      user = User.create!(email: 'reg1@example.com', password: '123456', first_name: 'Example', last_name: 'Registrar', telephone: '000-000-0000')
      user.add_role 'registrar'
      user = User.create!(email: 'reg2@example.com', password: '123456', first_name: 'Example', last_name: 'Registrar', telephone: '000-000-0000')
      user.add_role 'registrar'
      user = User.create!(email: 'admin@example.com', password: '123456', first_name: 'Example', last_name: 'Admin', telephone: '000-000-0000')
      user.grant_admin unless user.admin?
      puts 'Done!'
    end
    

  end
end
