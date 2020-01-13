require 'csv'
require 'creek'

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

    desc "Load records"
    task load_records: :environment do

      # Given a literal file and a statistical file, pull out some mortality data
      literal = ENV['LITERAL']
      statistical = ENV['STATISTICAL']
      count = (ENV['COUNT'] || 10).to_i

      raise "Please provide the literal file (LITERAL=<file>.csv) and statistical file (STATISTICAL=<file>.xlsx)" unless literal and statistical

      # Load the literal data
      literal_records = CSV.read(literal, :encoding => 'ISO-8859-1', :headers => true)

      # Load the statistical data
      statistical_file = Creek::Book.new(statistical)
      statistical_records = statistical_file.sheets[0]
      statistical_header = statistical_records.rows.first

      # Iterate through the first <count> rows
      count.times do |index|

        lrow = literal_records[index]

        # Grab the matching statistical row and key it against the header
        srow = statistical_records.rows.detect { |srow| Hash[statistical_header.values.zip(srow.values)]['State file number'] == lrow['State File Number'] }
        raise "Could not find a matching statistical row for state file number #{row['State File Number']}" unless srow
        srow = Hash[statistical_header.values.zip(srow.values)]

        # Build the Nightingale internal structure, inventing a name for the decedent
        record = {
          "decedentName.firstName" => "Demo#{rand(10000)}",
          "decedentName.lastName" => "Example#{rand(10000)}",

          "sex.sex" => srow["Sex"] == "F" ? "Female" : "Male",
          "dateOfBirth.dateOfBirth" => DateTime.strptime(srow["Date of Birth"], '%m/%d/%Y').to_s,

          "cod.immediate" => lrow["Cause of Death - Line A"],
          "cod.immediateInt" => lrow["Interval Time - Line A"],
          "cod.under1" =>  lrow["Cause of Death - Line B"],
          "cod.under1Int" =>  lrow["Interval Time - Line B"],
          "cod.under2" =>  lrow["Cause of Death - Line C"],
          "cod.under2Int" =>  lrow["Interval Time - Line C"],
          "cod.under3" =>  lrow["Cause of Death - Line D"],
          "cod.under3Int" =>  lrow["Interval Time - Line D"],

          "contributingCauses.contributingCauses" => lrow["Other Significant Conditions"],

          "dateOfDeath.dateOfDeath" => DateTime.strptime(srow["Date of Death"], '%m/%d/%Y').to_s,
          "dateCertified.dateCertified" => DateTime.strptime(srow["Date Received"], '%m/%d/%Y').to_s
        }

        # Pick a certifier
        user = User.find_by(first_name: 'Example', last_name: 'Certifier')

        # Create new record
        workflow = Workflow.where(initiator_role: user.roles.first.name).order('created_at').last
        step_flow = workflow.step_flows.first
        death_record = DeathRecord.new(creator: user,
                                       owner: user,
                                       workflow: workflow,
                                       step_flow: step_flow)
        step_status = StepStatus.create(death_record: death_record,
                                        current_step: step_flow.current_step,
                                        next_step: step_flow.next_step,
                                        previous_step: step_flow.previous_step)
        death_record.step_status = step_status
        death_record.save
        steps_content_hash = death_record.separate_step_contents(record)
        death_record.steps.each do |step|
          if steps_content_hash[step.name]
            StepContent.update_or_create_new(death_record: death_record,
                                             step: step,
                                             contents: steps_content_hash[step.name],
                                             editor: user)
          end
        end
        death_record.notify = true
        death_record.save(validate: false)

        puts "Created record with ID #{death_record.id.to_s}"

      end

    end

  end
end
