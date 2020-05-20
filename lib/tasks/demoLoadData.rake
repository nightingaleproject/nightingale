require 'csv'
require 'creek'

# Rake tasks for loading data sets to Nightingale for demo use.
# Pre-requsites
#   set up the database
#     bundle exec rake db:setup
#     bundle exec rake nightingale:demo:setup
#   set 3 environment variables
#     export LITERAL=./datasets/DeathLiteral2011.csv
#     export STATISTICAL=./datasets/DeathStatistical2011.xlsx
#     export COUNT=50
#   Note the literal file must be .csv, while the statistical file must be xlsx
#     COUNT is optional and defaults to 10
#
#   rake nightingale:demo:load_records

namespace :nightingale do
  namespace :demo do

    # get the race of the deceased
    # return a [ string1, [ string2, string3 ] ]
    #   where string1 is either "Known" or "Unknown"
    #         and string2 is the CDC code
    #         and string3 is the CDC display string 
    def get_race_info(srow)
      # puts "   in get_race_info:  #{srow["State file number"]}"

        columnHeaderMapping = { # partial column headers mapped from statistical_records file to nightingale-defined constant (in vrdr-dotnet/VRDR/MortalityData.cs)
          #"CN1"=>"Hispanic No", "CO1"=>"Hispanic Mexican", "CP1"=>"Hispanic Puerto Rican", "CQ1"=>"Hispanic Cuban", "CR1"=>"Hispanic Other", 
          "CS1"=>"Race White", 
          "CT1"=>"Race Black", 
          "CU1"=>"Race Amer Indian Alaskan", 
          "CV1"=>"Race Asian Indian", 
          "CW1"=>"Race Chinese", 
          "CX1"=>"Race Filipino", 
          "CY1"=>"Race Japanese", 
          "CZ1"=>"Race Korean", 
          "DA1"=>"Race Vietnamese", 
          "DB1"=>"Race Other Asian", 
          "DC1"=>"Race Hawaiian", 
          "DD1"=>"Race Guamanian or Chamorro", 
          "DE1"=>"Race Samoan", 
          "DF1"=>"Race Other Pacific Islander", 
          "DG1"=>"Race Other",
          #"DH1"=>"Race Tribe First", "DI1"=>"Race Tribe Second", "DJ1"=>"Race Other Asian First", "DK1"=>"Race Other Asian Second", "DL1"=>"Race Other Pacific Islander First", "DM1"=>"Race Other Pacific Islander Second", "DN1"=>"Race Other First", "DO1"=>"Race Other Second"
        }
                  
        # this function assumes that the spreadsheet has a column where a "Y" is true for the race/ethnicity
        #   and that the order of the columns are as specified by columnHeader
        #   It stops scanning as soon as it finds the first "Y"
        
        raceKnown = false # assume we do not know the race to start
        racefound = false
        raceValue = nil
        colString = nil
        columnHeaderMapping.each do |_k,colname|
          if ( srow[colname] == 'Y')
            racefound = true
            colString = colname
            case colname
            when "Race White"
              raceValue = [ "2106-3", "White" ]
            when "Race Black"
              raceValue = [ "2054-5", "Black or African American" ]
            when "Race Amer Indian Alaskan"
              raceValue = [ "1002-5", "American Indian or Alaska Native" ]
            when "Race Asian Indian"
              raceValue = [ "2029-7", "Asian Indian" ]
            when "Race Chinese"
              raceValue = [ "2034-7", "Chinese" ]
            when "Race Filipino"
              raceValue = [ "2036-2", "Filipino" ]
            when "Race Japanese"
              raceValue = [ "2039-6", "Japanese" ]
            when "Race Korean"
              raceValue = [ "2040-4", "Korean" ]
            when "Race Vietnamese"
              raceValue = [ "2047-9", "Vietnamese" ]
            when "Race Other Asian"
              raceValue = [ "2028-9", "Asian" ]
            when "Race Hawaiian"
              raceValue = [ "2079-2", "Native Hawaiian" ]
            when "Race Guamanian or Chamorro"
              raceValue = [ "2086-7", "Guamanian or Chamorro" ]
            when "Race Samoan"
              raceValue = [ "2080-0", "Samoan" ]
            when "Race Other Pacific Islander"
              raceValue = [ "2076-8", "Native Hawaiian or Other Pacific Islander" ]
            when "Race Other"
              raceKnown = false
            end
          end  
          if racefound
            raceKnown = true
            break
          end          
        end
      # puts "       #{colString}"
      [ raceKnown ? "Known" : "Unknown", raceKnown ? raceValue : nil ]
    end


    desc "Load records"
    task load_records: :environment do

      # Given a literal file and a statistical file, pull out COUNT mortality data
      literal = ENV['LITERAL']
      statistical = ENV['STATISTICAL']
      count = (ENV['COUNT'] || 10).to_i

      raise "Please provide the literal file (LITERAL=<file>.csv) and statistical file (STATISTICAL=<file>.xlsx)" unless literal and statistical

      # Load the literal data
      literal_records = CSV.read(literal, :encoding => 'ISO-8859-1', :headers => true)
      literal_header = CSV.open(literal, &:readline)
      # puts " literal file's header = #{literal_header}"

      # Load the statistical data
      statistical_file = Creek::Book.new(statistical)
      statistical_records = statistical_file.sheets[0]
      statistical_header = statistical_records.rows.first

      #simple test to make sure the format of the input has not changed
      if statistical_header != {"A1"=>"State file number", "B1"=>"Sex", "C1"=>"Date of Death", "D1"=>"Date of Death month", "E1"=>"Date of Death day", "F1"=>"Date of Death year", "G1"=>"Race", "H1"=>"Age Unit", "I1"=>"Age", "J1"=>"Hispanic NCHS bridge", "K1"=>"Date of Birth", "L1"=>"Date of Birth month", "M1"=>"Date of Birth day", "N1"=>"Date of Birth year", "O1"=>"Death City", "P1"=>"Death County", "Q1"=>"Death City WA code", "R1"=>"Death County WA code", "S1"=>"Facility name", "T1"=>"State of birth code", "U1"=>"Marital", "V1"=>"Residence City FIPS code", "W1"=>"Residence County FIPS code", "X1"=>"Residence City WA code", "Y1"=>"Residence County WA code", "Z1"=>"Underlying COD code", "AA1"=>"Underlying COD code 3", "AB1"=>"Autopsy", "AC1"=>"Manner", "AD1"=>"Injury date", "AE1"=>"Injury Date month", "AF1"=>"Injury Date day", "AG1"=>"Injury Date year", "AH1"=>"Injury time - hour", "AI1"=>"Injury time - minute", "AJ1"=>"Time of Injury Modifier", "AK1"=>"Injury at work", "AL1"=>"Injury Place", "AM1"=>"Injury City", "AN1"=>"Injury County", "AO1"=>"Injury City WA code", "AP1"=>"Injury County WA code", "AQ1"=>"Time of Death hour", "AR1"=>"Time of Death minute", "AS1"=>"Certifier Designation", "AT1"=>"Occupation Milham", "AU1"=>"Place of Death type", "AV1"=>"Residence Zip", "AW1"=>"Education", "AX1"=>"Residence state FIPS code", "AY1"=>"Death State", "AZ1"=>"Time of Death Modifier", "BA1"=>"Age Years", "BB1"=>"Occupation", "BC1"=>"Industry", "BD1"=>"Injury State", "BE1"=>"Armed Forces", "BF1"=>"Residence City Limits", "BG1"=>"Disposition", "BH1"=>"Disposition Date", "BI1"=>"Disposition Date month", "BJ1"=>"Disposition Date day", "BK1"=>"Disposition Date year", "BL1"=>"Funeral Home Name", "BM1"=>"ME Coroner Referred", "BN1"=>"Date Received", "BO1"=>"Record Axis Code 1", "BP1"=>"Record Axis Code 2", "BQ1"=>"Record Axis Code 3", "BR1"=>"Record Axis Code 4", "BS1"=>"Record Axis Code 5", "BT1"=>"Record Axis Code 6", "BU1"=>"Record Axis Code 7", "BV1"=>"Record Axis Code 8", "BW1"=>"Record Axis Code 9", "BX1"=>"Record Axis Code 10", "BY1"=>"Record Axis Code 11", "BZ1"=>"Record Axis Code 12", "CA1"=>"Record Axis Code 13", "CB1"=>"Record Axis Code 14", "CC1"=>"Record Axis Code 15", "CD1"=>"Record Axis Code 16", "CE1"=>"Record Axis Code 17", "CF1"=>"Record Axis Code 18", "CG1"=>"Record Axis Code 19", "CH1"=>"Record Axis Code 20", "CI1"=>"Injury ACME Place", "CJ1"=>"Birthplace Country", "CK1"=>"Local File Number", "CL1"=>"Death Zip Code", "CM1"=>"Education 8 or Less", "CN1"=>"Hispanic No", "CO1"=>"Hispanic Mexican", "CP1"=>"Hispanic Puerto Rican", "CQ1"=>"Hispanic Cuban", "CR1"=>"Hispanic Other", "CS1"=>"Race White", "CT1"=>"Race Black", "CU1"=>"Race Amer Indian Alaskan", "CV1"=>"Race Asian Indian", "CW1"=>"Race Chinese", "CX1"=>"Race Filipino", "CY1"=>"Race Japanese", "CZ1"=>"Race Korean", "DA1"=>"Race Vietnamese", "DB1"=>"Race Other Asian", "DC1"=>"Race Hawaiian", "DD1"=>"Race Guamanian or Chamorro", "DE1"=>"Race Samoan", "DF1"=>"Race Other Pacific Islander", "DG1"=>"Race Other", "DH1"=>"Race Tribe First", "DI1"=>"Race Tribe Second", "DJ1"=>"Race Other Asian First", "DK1"=>"Race Other Asian Second", "DL1"=>"Race Other Pacific Islander First", "DM1"=>"Race Other Pacific Islander Second", "DN1"=>"Race Other First", "DO1"=>"Race Other Second", "DP1"=>"Residence Tribal Reservation Code", "DQ1"=>"Residence Length Units", "DR1"=>"Residence Length", "DS1"=>"Informant Relationship", "DT1"=>"Autopsy Available", "DU1"=>"Injury Zip code", "DV1"=>"Pregnancy", "DW1"=>"Tobacco", "DX1"=>"Injury Transportation", "DY1"=>"Date of Death Modifier", "DZ1"=>"Race Summary", "EA1"=>"Disposition Place Name", "EB1"=>"Bridge race", "EC1"=>"ACME line 1", "ED1"=>"ACME line 2", "EE1"=>"ACME line 3", "EF1"=>"ACME line 4", "EG1"=>"ACME line 5", "EH1"=>"ACME line 6", "EI1"=>"ACME line 7", "EJ1"=>"ACME line 8", "EK1"=>"ACME line 9", "EL1"=>"ACME line 10", "EM1"=>"ACME line 11", "EN1"=>"ACME line 12", "EO1"=>"ACME line 13", "EP1"=>"ACME line 14", "EQ1"=>"ACME line 15", "ER1"=>"ACME line 16", "ES1"=>"ACME line 17", "ET1"=>"ACME line 18", "EU1"=>"ACME line 19", "EV1"=>"ACME line 20", "EW1"=>"ACME sequence 1", "EX1"=>"ACME sequence 2", "EY1"=>"ACME sequence 3", "EZ1"=>"ACME sequence 4", "FA1"=>"ACME sequence 5", "FB1"=>"ACME sequence 6", "FC1"=>"ACME sequence 7", "FD1"=>"ACME sequence 8", "FE1"=>"ACME sequence 9", "FF1"=>"ACME sequence 10", "FG1"=>"ACME sequence 11", "FH1"=>"ACME sequence 12", "FI1"=>"ACME sequence 13", "FJ1"=>"ACME sequence 14", "FK1"=>"ACME sequence 15", "FL1"=>"ACME sequence 16", "FM1"=>"ACME sequence 17", "FN1"=>"ACME sequence 18", "FO1"=>"ACME sequence 19", "FP1"=>"ACME sequence 20", "FQ1"=>"ACME cause category 1", "FR1"=>"ACME cause category 2", "FS1"=>"ACME cause category 3", "FT1"=>"ACME cause category 4", "FU1"=>"ACME cause category 5", "FV1"=>"ACME cause category 6", "FW1"=>"ACME cause category 7", "FX1"=>"ACME cause category 8", "FY1"=>"ACME cause category 9", "FZ1"=>"ACME cause category 10", "GA1"=>"ACME cause category 11", "GB1"=>"ACME cause category 12", "GC1"=>"ACME cause category 13", "GD1"=>"ACME cause category 14", "GE1"=>"ACME cause category 15", "GF1"=>"ACME cause category 16", "GG1"=>"ACME cause category 17", "GH1"=>"ACME cause category 18", "GI1"=>"ACME cause category 19", "GJ1"=>"ACME cause category 20", "GK1"=>"ACME nature of injury flag 1", "GL1"=>"ACME nature of injury flag 2", "GM1"=>"ACME nature of injury flag 3", "GN1"=>"ACME nature of injury flag 4", "GO1"=>"ACME nature of injury flag 5", "GP1"=>"ACME nature of injury flag 6", "GQ1"=>"ACME nature of injury flag 7", "GR1"=>"ACME nature of injury flag 8", "GS1"=>"ACME nature of injury flag 9", "GT1"=>"ACME nature of injury flag 10", "GU1"=>"ACME nature of injury flag 11", "GV1"=>"ACME nature of injury flag 12", "GW1"=>"ACME nature of injury flag 13", "GX1"=>"ACME nature of injury flag 14", "GY1"=>"ACME nature of injury flag 15", "GZ1"=>"ACME nature of injury flag 16", "HA1"=>"ACME nature of injury flag 17", "HB1"=>"ACME nature of injury flag 18", "HC1"=>"ACME nature of injury flag 19", "HD1"=>"ACME nature of injury flag 20"}
        puts " statistical file's header has changed!  Cannot proceed!"
        exit(1)
      end
      if literal_header != ["State File Number", "Cause of Death - Line A", "Cause of Death - Line B", "Cause of Death - Line C", "Cause of Death - Line D", "Interval Time - Line A", "Interval Time - Line B", "Interval Time - Line C", "Interval Time - Line D", "Other Significant Conditions", "How Injury Occurred", "Place of Injury"]
        puts " literal file's header has changed!  Cannot proceed"
        exit(2)
      end
      

      # Iterate through the first <count> rows
      count.times do |index|

        lrow = literal_records[index]

        # Grab the matching statistical row and key it against the header
        srow = statistical_records.rows.detect { |srow| Hash[statistical_header.values.zip(srow.values)]['State file number'] == lrow['State File Number'] }
        raise "Could not find a matching statistical row for state file number #{row['State File Number']}" unless srow
        srow = Hash[statistical_header.values.zip(srow.values)]

        raceInfo = get_race_info(srow)

        # Build the Nightingale internal structure, inventing a name for the decedent
        record = {
          "certificateNumber" => lrow["State File Number"],
          
          "armedForcesService.armedForcesService" => srow["Armed Forces"],
          "autopsyPerformed.autopsyPerformed" => srow["Autopsy"],
          "autopsyAvailableToCompleteCauseOfDeath.autopsyAvailableToCompleteCauseOfDeath" => srow["Autopsy Available"],
          "didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath" => srow["Tobacco"],

          "meOrCoronerContacted.meOrCoronerContacted" => srow["ME Coroner Referred"],
          "certifierType.certifierType" => srow["Certifier Designation"],

          "cod.immediate" => lrow["Cause of Death - Line A"],
          "cod.immediateInt" => lrow["Interval Time - Line A"],
          "cod.under1" =>  lrow["Cause of Death - Line B"],
          "cod.under1Int" =>  lrow["Interval Time - Line B"],
          "cod.under2" =>  lrow["Cause of Death - Line C"],
          "cod.under2Int" =>  lrow["Interval Time - Line C"],
          "cod.under3" =>  lrow["Cause of Death - Line D"],
          "cod.under3Int" =>  lrow["Interval Time - Line D"],

          "contributingCauses.contributingCauses" => lrow["Other Significant Conditions"],

          "dateOfBirth.dateOfBirth" => DateTime.strptime(srow["Date of Birth"], '%m/%d/%Y').to_s,
          "dateOfDeath.dateOfDeath" => DateTime.strptime(srow["Date of Death"], '%m/%d/%Y').to_s,
          # "datePronouncedDead.datePronouncedDead" => ???
          
          # "decedentAddress.street" => ???,
          # "decedentAddress.city" => ???,
          "decedentAddress.state" => srow["Residence state FIPS code"],
          "decedentAddress.zip" => srow["Residence Zip"],
          
          "detailsOfInjuryLocation.name" => srow["Injury Place"],
          # "detailsOfInjuryLocation.street" => ???,
          "detailsOfInjuryLocation.city" => srow["Injury City"],
          "detailsOfInjuryLocation.state" => srow["Injury State"],
          "detailsOfInjuryLocation.zip" => srow["Injury Zip code"],
          
          # "locationOfDeath.name" => ???,
          # "locationOfDeath.street" => ???,
          "locationOfDeath.city" => srow["Death City"],
          "locationOfDeath.state" => srow["Death State"],
          "locationOfDeath.zip" => srow["Death Zip Code"],
          
          "funeralFacility.name" => srow["Funeral Home Name"],
          # "funeralFacility.street" => ???,
          # "funeralFacility.city" => ???,
          # "funeralFacility.state" => ???,
          # "funeralFacility.zip" => ???,
          
          # "personCompletingCauseOfDeathAddress.name" => ???,
          # "personCompletingCauseOfDeathAddress.street" => ???,
          # "personCompletingCauseOfDeathAddress.city" => ???,
          # "personCompletingCauseOfDeathAddress.state" => ???,
          # "personCompletingCauseOfDeathAddress.zip" => ???,

          # "placeOfBirth.city" => ???,
          "placeOfBirth.state" => srow["State of birth code"],
          "placeOfBirth.country" => srow["Birthplace Country"],

          "placeOfDisposition.name" => srow["Disposition Place Name"],
          # "placeOfDisposition.city" => ???,
          # "placeOfDisposition.state" => ???,
          # "placeOfDisposition.country" => ???,

          "decedentName.firstName" => "Demo#{rand(10000)}",
          "decedentName.lastName" => "Example#{rand(10000)}",

          # "personCompletingCauseOfDeathName.firstName" => ???,
          # "personCompletingCauseOfDeathName.middleName" => ???,
          # "personCompletingCauseOfDeathName.lastName" => ???,

          # "education.education" => srow["Education"], # ??? need string or code ("SEC") instead of int

          # "motherName.lastName" => ???,
          # ""mannerOfDeath.mannerOfDeath" => ???"

          "maritalStatus.maritalStatus" => srow["Marital"],

          "sex.sex" => srow["Sex"] == "F" ? "Female" : "Male",

          # "ssn.ssn1" => ???,
          # "ssn.ssn2" => ???,
          # "ssn.ssn3" => ???,

          "race.race.option" => raceInfo[0],
          "race.race.specify" => raceInfo[1],
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
          # record.each { | key, value |
          #   puts "    #{key}: #{value}" unless value.nil?
          # }

        end

      end

    end

  end
end
