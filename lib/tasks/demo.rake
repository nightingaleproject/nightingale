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

      # Mapping from possible yes/no values to the yes/no values that nightingale expects
      yes_no_map = {
        "yes" => "Yes",
        "y" => "Yes",
        "no" => "No",
        "n" => "No"
      }
      # Other mappings
      tobacco_map = {
        "Y" => "Yes",
        "N" => "No",
        "P" => "Probably",
        "U" => "Unknown"
      }
      certifier_type_map = {
        1 => "Physician (Certifier)", # PHYSICIAN
        2 => "Medical Examiner", # CORONER/ME
        3 => "Physician (Certifier)", # DO
        4 => "Other", # CHIROPRACTOR
        5 => "Other", # SANIPRACTOR
        6 => "Other", # PHYSICIAN ASSISTANT
        7 => "Other", # ARNP
        8 => "Other", # NOT APPLICABLE
        9 => "Other" # UNKNOWN
      }
      certifier_type_map.default = "Other"

      # Iterate through the first <count> rows
      count.times do |index|

        lrow = literal_records[index]

        # Grab the matching statistical row and key it against the header
        srow = statistical_records.rows.detect { |srow| Hash[statistical_header.values.zip(srow.values)]['State file number'] == lrow['State File Number'] }
        raise "Could not find a matching statistical row for state file number #{row['State File Number']}" unless srow
        srow = Hash[statistical_header.values.zip(srow.values)]

        # Build the Nightingale internal structure, inventing a name for the decedent and setting death
        # location jurisdiction to MA and SSN to a constant made up value
        record = {
          "certificateNumber" => lrow["State File Number"][-6,6].to_i, # Just use the last 6 digits

          "deathLocationJurisdiction" => "MA",

          "decedentName.firstName" => "Demo#{rand(10000)}",
          "decedentName.lastName" => "Example#{rand(10000)}",

          "sex.sex" => srow["Sex"] == "F" ? "Female" : "Male",

          "armedForcesService.armedForcesService" => yes_no_map[srow["Armed Forces"].downcase],
          "autopsyPerformed.autopsyPerformed" => yes_no_map[srow["Autopsy"].downcase],
          "autopsyAvailableToCompleteCauseOfDeath.autopsyAvailableToCompleteCauseOfDeath" => yes_no_map[srow["Autopsy Available"].downcase],
          "meOrCoronerContacted.meOrCoronerContacted" => yes_no_map[srow["ME Coroner Referred"].downcase],

          "didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath" => tobacco_map[srow["Tobacco"]],

          "cod.immediate" => lrow["Cause of Death - Line A"],
          "cod.immediateInt" => lrow["Interval Time - Line A"],
          "cod.under1" =>  lrow["Cause of Death - Line B"],
          "cod.under1Int" =>  lrow["Interval Time - Line B"],
          "cod.under2" =>  lrow["Cause of Death - Line C"],
          "cod.under2Int" =>  lrow["Interval Time - Line C"],
          "cod.under3" =>  lrow["Cause of Death - Line D"],
          "cod.under3Int" =>  lrow["Interval Time - Line D"],

          "contributingCauses.contributingCauses" => lrow["Other Significant Conditions"],

          "certifierType.certifierType" => certifier_type_map[srow["Certifier Designation"].to_i],

          "dateOfBirth.dateOfBirth" => DateTime.strptime(srow["Date of Birth"], '%m/%d/%Y').to_s,
          "dateOfDeath.dateOfDeath" => DateTime.strptime(srow["Date of Death"], '%m/%d/%Y').to_s,
          "dateCertified.dateCertified" => DateTime.strptime(srow["Date Received"], '%m/%d/%Y').to_s,

          "decedentAddress.state" => srow["Residence state FIPS code"],
          "decedentAddress.zip" => srow["Residence Zip"],

          "detailsOfInjuryLocation.name" => srow["Injury Place"],
          "detailsOfInjuryLocation.city" => srow["Injury City"],
          "detailsOfInjuryLocation.state" => srow["Injury State"],
          "detailsOfInjuryLocation.zip" => srow["Injury Zip code"],

          "locationOfDeath.city" => srow["Death City"],
          "locationOfDeath.state" => srow["Death State"],
          "locationOfDeath.zip" => srow["Death Zip Code"],

          "placeOfBirth.state" => srow["State of birth code"],
          "placeOfBirth.country" => srow["Birthplace Country"],

          "funeralFacility.name" => srow["Funeral Home Name"],
          "placeOfDisposition.name" => srow["Disposition Place Name"],

          "ssn.ssn1" => "555",
          "ssn.ssn2" => "11",
          "ssn.ssn3" => "1234"

          # TODO: add these, and these also have to be mapped in the Nightingale => FHIR mapper
          # "placeOfDeath" => "Place of Death type" (lookup) -> Dead on arrival at hospital", "Death in home", "Death in hospice", "Death in hospital", "Death in hospital-based emergency department or outpatient department", "Death in nursing home or long term care facility", "Unknown", "Other
          # time of death: map hour and minute and approximate thingy
          # deathResultedFromInjuryAtWork (yes or no)
          # transportation (Vehicle driver, Passenger, Pedestrian, Other) from Injury Transportation field
          # pregnancy status (Not pregnant within past year, Pregnant at time of death, Not pregnant, but pregnant within 42 days of death, Not pregnant, but pregnant 43 days to 1 year before death, Unknown if pregnant within the past year)
          # manner of death
          # marital status
          # education
          # usual occupation
          # method of disposition (from disposition column)
          # Add fake family info?

          # TODO: Leave out race information until IG representation is solidified
        }

        # Pick a certifier
        user = User.find_by(first_name: 'Example', last_name: 'Certifier')

        DeathRecord.transaction do

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
end
