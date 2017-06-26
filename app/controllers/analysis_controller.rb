# Analysis controller
class AnalysisController < ApplicationController
  before_action :authenticate_user!

  def index
    verify_is_admin
  end

  # Function which will return chart information to front end.
  def analyze_causes
    verify_is_admin
    decedent_age_range = JSON.parse(params[:age_range]).collect{|i| i.to_i}
    age_keys = {0..9 => "Ages 0-9",
                10..19 => "Ages 10-19",
                20..29 => "Ages 20-29",
                30..39 => "Ages 30-39",
                40..49 => "Ages 40-49",
                50..59 => "Ages 50-59",
                60..69 => "Ages 60-69",
                70..79 => "Ages 70-79",
                80..89 => "Ages 80-89",
                90..99 => "Ages 90-99",
                100..120 => "Ages 100 and up"}
    all_ages = []
    partial_age_hash = {}
    # Fill up partial hash for ages which will be used to construct keys for decedent_frequency hash.
    decedent_age_range.each do |val|
      if val < 100
        (val..val + 9).each do |age|
          all_ages.push(age)
          partial_age_hash[(val..val+9)] = age_keys[(val..val+9)]
        end
      else
        (val..val + 20).each do |age|
          all_ages.push(age)
          partial_age_hash[(100..120)] = age_keys[(100..120)]
        end
      end
    end

    # Regular expression that will determine if start year and end years are both positive integers.
    if !/\A\d+\z/.match(params[:start_year]) || !/\A\d+\z/.match(params[:end_year]) || !/\A\d+\z/.match(params[:num_causes])
      render json: {}
      return
    end
    decedent_sex = JSON.parse(params[:sex])
    cause_of_death = params[:cause_of_death]
    num_causes = params[:num_causes].to_i
    start_year = params[:start_year].to_i
    end_year = params[:end_year].to_i
    decedent_race = JSON.parse(params[:race])
    decedent_residence_zip = params[:residence_zipcode]
    decedent_death_zip = params[:death_zipcode]
    criteria = JSON.parse(params[:specified_criteria])
    decedent_frequency = {}
    decedent_frequency_keys = []
    params_specified = []
    target_decedent_cods = []
    result_query = DeathRecord
    if cause_of_death != ""
      # For the case of American Indian or Alaskan Native (specify tribe), get rid of the (specify tribe) part.
      decedent_race.each do |race|
        if race.include?("(specify tribe)")
          race = race.gsub!(" (specify tribe)", "")
        end
      end

      # If the race, sex, and age of the decedents in the form are all filled out,
      if decedent_race.length > 0 && decedent_sex.length > 0 && decedent_age_range.length > 0
        decedent_race.each do |race|
          decedent_sex.each do |sex|
            decedent_age_range.each do |age|
              decedent_frequency[race + " " + sex + " " + partial_age_hash.select{|a| a === age}.values.first] = {}
            end
          end
        end
        # If the race and sex are specified to search under but no age is specified.
      elsif decedent_race.length > 0 && decedent_sex.length > 0
        decedent_race.each do |race|
          decedent_sex.each do |sex|
            decedent_frequency[race + " " + sex] = {}
          end
        end
        # If the race and age ranges are specified but not sex.
      elsif decedent_race.length >0 && decedent_age_range.length > 0
        decedent_race.each do |race|
          decedent_age_range.each do |age|
            decedent_frequency[race + " " + partial_age_hash.select{|a| a === age}.values.first] = {}
        end
      end
      # If the sex and age range are specified but not race.
      elsif decedent_sex.length > 0 && decedent_age_range.length > 0
        decedent_sex.each do |sex|
          decedent_age_range.each do |age|
            decedent_frequency[sex + " " + partial_age_hash.select{|a| a === age}.values.first] = {}
          end
        end
      # Only race was specified.
      elsif decedent_race.length > 0
        decedent_race.each do |race|
          decedent_frequency[race] = {}
        end
      # Only sex was specified.
      elsif decedent_sex.length > 0
        decedent_sex.each do |sex|
          decedent_frequency[sex] = {}
        end
      # Only age ranges were specified.
      elsif decedent_age_range.length > 0
        decedent_age_range.each do |age|
          decedent_frequency[partial_age_hash.select{|a| a === age}.values.first] = {}
        end
      # No filters provided. Accumulate statistics for all individuals in the records.
      else
        decedent_frequency["All Individuals"] = {}
      end
    end
  # Store all the necessary queries in the params_specified array which will be looped over in the end.
  if decedent_sex.length == 1
    params_specified.push("contents ->> 'sex.sex' = '" + decedent_sex[0] + "'")
  elsif decedent_sex.length == 2
    params_specified.push("contents ->> 'sex.sex' = 'Male' or contents ->> 'sex.sex' = 'Female' or contents ->> 'sex.sex' = 'Unknown'")
  end

  if cause_of_death != ""
    params_specified.push("contents ->> 'cod.immediate' = '" + cause_of_death + "'")
  end

  if !decedent_residence_zip.empty?
    params_specified.push("contents ->> 'decedentAddress.zip' = '" + decedent_residence_zip + "'")
  end

  if !decedent_death_zip.empty?
    params_specified.push("contents ->> 'locationOfDeath.zip' = '" + decedent_death_zip + "'")
  end

  if criteria.include?("served_armed_forces")
    params_specified.push("contents ->> 'armedForcesService.armedForcesService' = 'Yes'")
  end

  if criteria.include?("tobacco_cause")
    params_specified.push("contents ->> 'didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath' = 'Yes'")
  end
  # Start of the query by searching for all of the patients with a specified cause of death.
  result_query = DeathRecord
  params_specified.each do |query|
    result_query= result_query.where(query)
  end
  result_query.find_each do |record|
    # Obtain birth year of decedent if available.
    record_birth_year = DateTime.parse(record.contents['dateOfBirth.dateOfBirth']).year if record.contents['dateOfBirth.dateOfBirth']
    # Obtain birth month of decedent if available.
    record_birth_month = DateTime.parse(record.contents['dateOfBirth.dateOfBirth']).month if record.contents['dateOfBirth.dateOfBirth']
    # Obtain birth day of decedent if available.
    record_birth_day = DateTime.parse(record.contents['dateOfBirth.dateOfBirth']).day if record.contents['dateOfBirth.dateOfBirth']
    # Obtain death year of decedent if available.
    record_death_year = DateTime.parse(record.contents['datePronouncedDead.datePronouncedDead']).year if record.contents['datePronouncedDead.datePronouncedDead']
    # Obtain death month of decedent if available.
    record_death_month = DateTime.parse(record.contents['datePronouncedDead.datePronouncedDead']).month if record.contents['datePronouncedDead.datePronouncedDead']
    # Obtain death day of decedent if available.
    record_death_day = DateTime.parse(record.contents['datePronouncedDead.datePronouncedDead']).day if record.contents['datePronouncedDead.datePronouncedDead']
    # Obtain sex of decedent if available.
    record_sex = record.contents['sex.sex'] if record.contents['sex.sex']
    # Obtain races of decedent if available.
    record_races_listed = JSON.parse(record.contents["race.race.specify"]) if record.contents["race.race.specify"]

    if record.contents["race.race.specify"]
      record_races_listed.each do |race|
        if race.include?("(specify tribe)")
          race = race.gsub!(" (specify tribe)", "")
          break
        end
      end
    end
    next if (record_birth_year.nil? || record_death_year.nil?) && decedent_age_range.length > 0
    age_at_death = -1
    # Only compute a proper age of death if the records are present for that decedent.
    if record_death_year && record_birth_year
      age_at_death = record_death_year - record_birth_year
      # Adjust age at death based upon time of birth and time of death.
      if record_death_month < record_birth_month
        age_at_death -= 1
      elsif record_death_month == record_birth_month
        if record_death_day < record_birth_day
          age_at_death -= 1
        end
      end
    end
    # Skip decedent if their gender was not specified and user asked to filter based on gender.
    next if record_sex.nil? && decedent_sex.length > 0
    # Skip decedent if their death year is before the start year specified or if their death year is after the end year specified.
    next if record_death_year < start_year || record_death_year > end_year
    # Skip if age of decedent is not within any of the age ranges specified by user.
    next if partial_age_hash.select{|a| a === age_at_death}.empty? && !partial_age_hash.empty?
    # Skip if decedent has no recorded race and user asked to filter based on race.
    next if !decedent_race.empty? && record_races_listed.nil?
    # Skip if decedent has no races in common with the races specified by the user.
    next if (!decedent_race.empty? && (record_races_listed & decedent_race).empty?)
    common_races = record_races_listed & decedent_race
    if cause_of_death != ""
      # Place into the hash based on the key containing the race, sex and age range.
      if decedent_race.length > 0 && decedent_sex.length > 0 && decedent_age_range.length > 0
        common_races.each do |race|
          modified_key = race + " " + record_sex + " " + partial_age_hash.select{|a| a === age_at_death}.values.first
          if decedent_frequency[modified_key].key?(record_death_year)
            decedent_frequency[modified_key][record_death_year] += 1
          else
            decedent_frequency[modified_key][record_death_year] = 1
          end
        end
      # Place into the hash based on the key containing the race and sex of decedent.
      elsif decedent_race.length > 0 && decedent_sex.length > 0
        common_races.each do |race|
          modified_key = race + " " + record_sex
          if decedent_frequency[modified_key].key?(record_death_year)
            decedent_frequency[modified_key][record_death_year] += 1
          else
            decedent_frequency[modified_key][record_death_year] = 1
          end
        end
      # Place into the hash based on the key containing the race and age range of decedent.
      elsif decedent_race.length > 0 && decedent_age_range.length > 0
        common_races.each do |race|
          modified_key = race + " " + partial_age_hash.select{|a| a === age_at_death}.values.first
          if decedent_frequency[modified_key].key?(record_death_year)
            decedent_frequency[modified_key][record_death_year] += 1
          else
            decedent_frequency[modified_key][record_death_year] = 1
          end
        end
      # Place into the hash based on the key containing the sex and age range of the decedent.
      elsif decedent_sex.length > 0 && decedent_age_range.length > 0
        modified_key = record_sex + " " + partial_age_hash.select{|a| a === age_at_death}.values.first
        if decedent_frequency[modified_key].key?(record_death_year)
          decedent_frequency[modified_key][record_death_year] += 1
        else
          decedent_frequency[modified_key][record_death_year] = 1
        end
      # Place into the hash based on the key containing just the races of decedents.
      elsif decedent_race.length > 0
        common_races.each do |race|
          if decedent_frequency[race].key?(record_death_year)
            decedent_frequency[race][record_death_year] += 1
          else
            decedent_frequency[race][record_death_year] = 1
          end
        end
      # Place into the hash based on the key containing just the sex of the decedent.
      elsif decedent_sex.length > 0
        if decedent_frequency[record_sex].key?(record_death_year)
          decedent_frequency[record_sex][record_death_year] += 1
        else
          decedent_frequency[record_sex][record_death_year] = 1
        end
      # Place into the hash based on the key containing just the age range.
      elsif decedent_age_range.length > 0
        if decedent_frequency[partial_age_hash.select{|a| a === age_at_death}.values.first].key?(record_death_year)
          decedent_frequency[partial_age_hash.select{|a| a === age_at_death}.values.first][record_death_year] += 1
        else
          decedent_frequency[partial_age_hash.select{|a| a === age_at_death}.values.first][record_death_year] = 1
        end
      else
        if decedent_frequency.key?("All Individuals")
          if decedent_frequency["All Individuals"].key?(record_death_year)
            decedent_frequency["All Individuals"][record_death_year] += 1
          else
            decedent_frequency["All Individuals"][record_death_year] = 1
          end
        end
      end
    else
      target_decedent_cods << record.contents['cod.immediate'] if record.contents['cod.immediate'].present?
    end
  end
  # For all of the years in each of the decedent type hashes that had no deaths in a particular year, make the value 0.
  if cause_of_death != ""
    (start_year..end_year).each do |year|
      decedent_frequency.each_value do |value|
        if !value.key?(year)
          value[year] = 0
        end
      end
    end
    render json: decedent_frequency
  else
    counts = target_decedent_cods.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
    hash_sent = {}
    num_counted = 0
    # Sort the hash in reverse order from highest cause of death to lowest and store the entries in the hash_sent hash.
    counts.sort_by {|k,v| v}.reverse.each do |key,val|
      hash_sent[key] = val
      num_counted += 1
      if num_counted == num_causes
        break
      end
    end
    render json: hash_sent
  end
end

  # Create a list of params which will be allowed to be sent and accessed by the controller.
  def analyze_params
    allows = [:age_range, :num_causes, :sex, :residence_zipcode, :death_zipcode, :race, :start_year, :end_year, :specified_criteria, :cause_of_death]
    params.permit(allows)
  end

  private

  def verify_is_admin
    current_user.nil? ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end
end
