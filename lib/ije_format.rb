require 'json'
require 'date'
require 'codez'
require 'street_address'
require 'geokit'
require 'ije/mortality_format'

=begin Note: For now, the appropriate fields have been added and processed.
Some fields such as country of death information are currently not fully
complete because Nightingale assumes that the decedent passed away in the
United States but that may not always be the case. In addition, obtaining the
appropriate FIPS encoding for different cities is an ongoing task.
=end
module IJEFormat

  # Function to appropriately format the date into the format MM/DD/YYYY
  def self.extract_date(record_hash, key, info)
    extracted = ""
    if record_hash.key?(key)
      extracted = record_hash[key]
    end
    if extracted.length < 10
      return ""
    end

    if info == "format"
      formatted_date = ""
      formatted_date += extracted[5..6] + extracted[8..9] + extracted[0..3]
      return formatted_date
    elsif info == "year"
      return extracted[0..3]
    elsif info == "day"
      return extracted[8..9]
    elsif info == "month"
      return extracted[5..6]
    elsif info == "time"
      if extracted.length < 5
        return ""
      else
        return extracted[0..1] + extracted[3..4]
      end
    end
  end

  # Helper function that will find the value from a specified key in the record_hash input.
  def self.lookup(record_hash, key, offset)
    val = ""
    if record_hash.key?(key)
      val = record_hash[key]
    end
    if val.empty?
      return ""
    end
    return val[0...[val.length, offset].min]
  end

  # Helper function to determine whether or not the spouse of a decedent is alive.
  def self.check_if_spouse_alive(record_hash, key)
    result = ""
    if record_hash.key?(key)
      result = record_hash[key]
    end
    spouse_living_hash =
    {
      "Married" => "1",
      "Married but seperated" => "1",
      "Widowed" => "2",
      "Widowed (but not remarried)" => "2",
      "Divorced (but not remarried)" => "8",
      "Never married" => "8",
      "Unknown" => "9"
    }
    if spouse_living_hash.key?(result)
      return spouse_living_hash[result]
    else
      return ""
    end
  end

  # Function to obtain the literals for the parameters which are categorized as Other and ask for specification.
  def self.extract_other(record_hash, key, specify, offset)
    term = "{}"
    if record_hash.key?(key)
      term = record_hash[key]
    end
    if term.empty?
      return ""
    end

    term = JSON.parse(term)
    if term.empty?
      return ""
    elsif term.key?(specify)
      return term[specify][0...[offset, term[specify].length].min]
    end
  end

  # Only give the social security number if it is complete.
  def self.obtain_ssn(record_hash)
    if !record_hash.key?("ssn1") || !record_hash.key?("ssn.ssn2") || !record_hash.key?("ssn.ssn3")
      return ""
    else
      return record_hash["ssn.ssn1"] + record_hash["ssn.ssn2"] + record_hash["ssn.ssn3"]
    end
  end

  # Function that will determine if decedent was of a particular Hispanic origin.
  def self.hispanic_origin_lookup(record_hash, ethnicity)
    isHispanic = "U"
    specified = "[]"
    if record_hash.key?("hispanicOrigin.hispanicOrigin.option")
      isHispanic = record_hash["hispanicOrigin.hispanicOrigin.option"]
    else
      return "U"
    end

    if record_hash.key?("hispanicOrigin.hispanicOrigin.specify")
      specified = record_hash["hispanicOrigin.hispanicOrigin.specify"]
    else
      return "U"
    end

    if !specified.empty?
      specified = JSON.parse(specified)
    else
      return "U"
    end
    if isHispanic == "No"
      return "N"
    elsif specified.include?(ethnicity)
      return "Y"
    else
      return "N"
    end
  end

  # Function to obtain the appropriate value for race.
  def self.prior_nchs_race_lookup(record_hash, key)
    term = []
    if record_hash.key?(key)
      term = record_hash[key]
    end
    if term.empty?
      return "9"
    end
    term = JSON.parse(term)
    nchs_single_race_hash =
    {
      "White" => "1",
      "Black" => "2",
      "American Indian or Alaskan Native (specify)" => "3",
      "Chinese" => "4",
      "Japanese" => "5",
      "Hawaiian" => "6",
      "Filipino" => "7",
      "Other Asian (specify)" => "8",
      "Other Pacific Islander (specify)" => "8",
      "Not Reported" => "9",
      "Asian Indian" => "A",
      "Korean" => "B",
      "Samoan" => "C",
      "Vietnamese" => "D",
      "Guamian" => "E",
      "Multi-racial" => "F"
    }
    if term.empty?
      return nchs_single_race_hash["Not Reported"]
    else
      if term.length > 1
        return nchs_single_race_hash["Multi-racial"]
      else
        return nchs_single_race_hash[term[0]]
      end
    end
  end

  # Function to parse a street address into a form that can be accepted by the StreetAddress gem.
  def self.parse_street(record_hash, street_key, city_key, state_key, zip_key, property)
    merged = ""
    if record_hash.key?(street_key)
      merged = record_hash[street_key] + ", "
    else
      return merged
    end

    if record_hash.key?(city_key)
      merged += record_hash[city_key] + ", "
    else
      merged += " ,"
    end

    if record_hash.key?(state_key)
      merged += record_hash[state_key] + ", "
    else
      merged += " ,"
    end

    if record_hash.key?(zip_key)
      merged += record_hash[zip_key]
    else
      merged += " "
    end
    if property == "latitude" || property == "longitude"
      result = Geokit::Geocoders::GoogleGeocoder.geocode merged
      if result.nil?
        return ""
      elsif result.ll.nil?
        return ""
      end
      result_ll = result.ll.split(",")
      if result_ll.length < 2
        return ""
      elsif property == "latitude"
        return result_ll[0][0...[17, result_ll[0].length].min]
      elsif property == "longitude"
        return result_ll[1][0...[17, result_ll[1].length].min]
      end
    end
    merged = StreetAddress::US.parse(merged)
    if merged.nil?
      return ""
    end
    if property == "number"
      if merged.number
        return merged.number[0...[10, merged.number.length].min]
      else
        return ""
      end
    elsif property == "prefix"
      if merged.prefix
        return merged.prefix[0...[10, merged.prefix.length].min]
      else
        return ""
      end
    elsif property == "street"
      if merged.street
        return merged.street[0...[50, merged.street.length].min]
      else
        return ""
      end
    elsif property == "street_type"
      if merged.street_type
        return merged.street_type[0...[10, merged.street_type.length].min]
      else
        return ""
      end
    elsif property == "suffix"
      if merged.suffix
        return merged.suffix[0...[10, merged.suffix.length].min]
      else
        return ""
      end
    elsif property == "zip"
      if merged.postal_code
        zipcode = merged.postal_code
        if merged.postal_code_ext
          zipcode += merged.postal_code_ext
        end
        return zipcode
      else
        return ""
      end
    end
  end

  # Function that obtains the code for the old NCHS Hispanic codes.
  def self.prior_nchs_hispanic_lookup(record_hash)
    isHispanic = ""
    if record_hash.key?("hispanicOrigin.hispanicOrigin.option")
      isHispanic = record_hash["hispanicOrigin.hispanicOrigin.option"]
    else
      return ""
    end
    prior_hispanic_hash =
    {
      "Non-Hispanic" => "0",
      "Mexican, Mexican American, Chicano" => "1",
      "Puerto Rican" => "2",
      "Cuban" => "3",
      "Other Spanish/Hispanic/Latino (specify)" => "5",
      "" => "9"
    }
    if isHispanic == "No"
      return prior_hispanic_hash["Non-Hispanic"]
    elsif record_hash.key?("hispanicOrigin.hispanicOrigin.specify")
      specified = record_hash["hispanicOrigin.hispanicOrigin.specify"]
      if specified.empty?
        return "9"
      end
      specified = JSON.parse(specified)
      if specified.empty?
        return "9"
      end
      return prior_hispanic_hash[specified[0]]
    end
  end

  # Function that obtains the appropriate code for manner of death.
  def self.manner_of_death_lookup(record_hash, key)
    term = ""
    if record_hash.key?(key)
      term = record_hash[key]
    end
    manner_hash = {
      "Natural" => "N",
      "Accident" => "A",
      "Suicide" => "S",
      "Homicide" => "H",
      "Pending Investigation" => "P",
      "Could not be determined" => "C"
    }
    if manner_hash.key?(term)
      return manner_hash[term]
    end
    return "C"
  end

    #Function that obtains the race code.
    def self.race_code_lookup(record_hash, key)
      races = []
      if record_hash.key?(key)
        races = record_hash[key]
      end
      if !races.empty?
        races = JSON.parse(races)
      else
        return ""
      end
      race_code_hash =
      {
        "White" => "01",
        "Black" => "02",
        "American Indian or Alaskan Native (specify tribe)" => "03",
        "Asian Indian" => "04",
        "Chinese" => "05",
        "Filipino" => "06",
        "Japanese" => "07",
        "Korean" => "08",
        "Vietnamese" => "09",
        "Other Asian (specify)" => "10",
        "Native Hawaiian" => "11",
        "Guamanian or Chamorro" => "12",
        "Samoan" => "13",
        "Other Pacific Islander (specify)" => "14",
        "Other (specify)" => "15"
      }

      if !races.empty?
        return race_code_hash[races[0]]
      else
        return ""
      end
    end

  # Function that will retrieve the appropriate NCHS Hispanic code for the decedent.
  def self.hispanic_nchs_lookup(record_hash)
    if record_hash["hispanicOrigin.hispanicOrigin.option"] == "Yes"
      return "200"

    elsif record_hash["hispanicOrigin.hispanicOrigin.option"] == "No"
      return "100"

    else
      return "900"
    end
  end

  # Function that will obtain the place of death of the decedent.
  def self.death_place_lookup(record_hash, key, specify)
    term = ""
    specified = "{}"
    if record_hash.key?(key)
      if !record_hash[key].nil?
        term = record_hash[key]
      end
    end
    if term.empty?
      return ""
    end
    if term == "Decedent's Home"
      return "4"
    elsif term == "Other (specify)"
      if record_hash.key?(specify)
        specified = record_hash[specify]
        if specified.empty?
          return ""
        else
          specified = JSON.parse(specified)
          if specified.key?("Other (specify)")
            return specified["Other (specify)"][0...[30, specified["Other (specify)"].length].min]
          else
            return ""
          end
        end
      end
    end
  end

  # Function that will determine the appropriate pregnancy code for the decedent.
  def self.pregnancy_lookup(record_hash, key)
    term = ""
    if record_hash.key?(key)
      term = record_hash[key]
    end
    pregnancy_status_hash =
    {
      "Not pregnant in the past year" => "1",
      "Pregnant at the time of death" => "2",
      "Not pregnant, but pregnant within 42 days of death" => "3",
      "Not pregnant, but pregnant 43 days to 1 year before death" => "4",
      "Unknown if pregnant within the past year" => "9"
    }
    if pregnancy_status_hash.key?(term)
      return pregnancy_status_hash[term]
    end
    return "9"
  end

  # Function that will obtain the appropriate certifier code for the individual who acts as the certifier.
  def self.certifier_lookup(record_hash, key, offset)
    certifier_info = ""
    if record_hash.key?(key)
      certifier_info = record_hash[key]
    else
      return ""
    end
    certifier_hash =
    {
      "Certifying Physician" => "D",
      "Pronouncing and Certifying Physician" => "P",
      "Medical Examiner/Coroner" => "M"
    }
    if certifier_hash.key?(certifier_info)
      return certifier_hash[certifier_info]
    else
      return certifier_info[0...[30, certifier_info.length].min]
    end
  end

  # Function that will find the appropriate marriage code of the decedent.
  def self.marriage_lookup(record_hash, key)
    term = "Unknown"
    if record_hash.key?(key)
      term = record_hash[key]
    end
    marriage_code =
    {
      "Married" => 'M',
      "Married but seperated" => 'A',
      "Widowed" => 'W',
      "Widowed (but not remarried)" => 'W',
      "Divorced (but not remarried)" => 'D',
      "Never married" => 'S',
      "Unknown" => 'U'
    }
    if marriage_code.key?(term)
      return marriage_code[term]
    end
    return "U"
  end

  # Function that will determine the appropriate edit flag.
  def self.edit_flag_lookup(term)
    flag_hash =
    {
      "Edit Passed" => "0",
      "Edit Failed, Data Queried, and Verified" => "1",
      "Edit Failed, Data Queried, but not Verified" => "2",
      "Edit Failed, Query Needed" => "4"
    }
    return flag_hash[term]
  end

  # Function that will obtain the code of the disposition site for the decedent.
  def self.disposition_lookup(record_hash, key)
    term = "Unknown"
    if record_hash.key?(key)
      term = record_hash[key]
    end
    disposition_hash =
    {
      "Burial" => "B",
      "Cremation" => "C",
      "Donation" => "D",
      "Entombment" => "E",
      "Removal from state" => "R",
      "Other (specify)" => "O",
      "Unknown" => "U"
    }
    if disposition_hash.key?(term)
      return disposition_hash[term]
    else
      return "O"
    end
  end

  # Function that will determine if decedent is of a particular race. Return Y if true, otherwise return N
  def self.race_lookup(record_hash, key, race)
    info = []
    if record_hash.key?(key)
      info = record_hash[key]
    end
    if info.empty?
      return "N"
    else
      info = JSON.parse(info)
      if info.include?(race)
        return "Y"
      else
        return "N"
      end
    end
  end

  # Function that will obtain the full race
  def self.decedent_literal_lookup(record_hash, key, race)
    term = "{}"
    if record_hash.key?(key)
      term = record_hash[key]
    else
      return ""
    end
    term = JSON.parse(term)
    if term.key?(race)
      return term[race][0...30]
    else
      return ""
    end
  end

  # Function that will obtain the appropriate code for a specified U.S. or Canadian territory.
  def self.territory_lookup(record_hash, state_key, city_key, country_key, literal = false)
    term = ""
    # Check to see if city is New York City since that is a separate territory.
    if record_hash.key?(city_key)
      if record_hash.key?(state_key)
        if record_hash[city_key] == "New York City" && record_hash[state_key] == "New York"
          term = "New York City"
        end
      end
    end

    if record_hash.key?(state_key) && term == ""
      term = record_hash[state_key]
    end

    territories_hash =
    {
      "Alabama" => "AL",
    	"Alaska" => "AK",
      "American Samoa" => "AS",
    	"Arizona" => "AZ",
    	"Arkansas" => "AR",
    	"California" => "CA",
    	"Colorado" => "CO",
    	"Connecticut" => "CT",
    	"Delaware" => "DE",
    	"District of Columbia" => "DC",
    	"Florida" => "FL",
    	"Georgia" => "GA",
      "Guam" => "GU",
    	"Hawaii" => "HI",
    	"Idaho" => "ID",
    	"Illinois" => "IL",
    	"Indiana" => "IN",
    	"Iowa" => "IA",
    	"Kansas" => "KS",
    	"Kentucky" => "KY",
    	"Louisiana" => "LA",
    	"Maine" => "ME",
    	"Maryland" => "MD",
    	"Massachusetts" => "MA",
    	"Michigan" => "MI",
    	"Minnesota" => "MN",
    	"Mississippi" => "MS",
    	"Missouri" => "MO",
    	"Montana" => "MT",
    	"Nebraska" => "NE",
    	"Nevada" => "NV",
    	"New Hampshire" => "NH",
    	"New Jersey" => "NJ",
    	"New Mexico" => "NM",
    	"New York" => "NY",
      "New York City" => "YC",
    	"North Carolina" => "NC",
    	"North Dakota" => "ND",
      "Northern Mariana Islands" => "MP",
    	"Ohio" => "OH",
    	"Oklahoma" => "OK",
    	"Oregon" => "OR",
    	"Pennsylvania" => "PA",
      "Puerto Rico" => "PR",
    	"Rhode Island" => "RI",
    	"South Carolina" => "SC",
    	"South Dakota" => "SD",
    	"Tennessee" => "TN",
    	"Texas" => "TX",
    	"Utah" => "UT",
    	"Vermont" => "VT",
      "Virgin Islands" => "VI",
    	"Virginia" => "VA",
    	"Washington" => "WA",
    	"West Virginia" => "WV",
    	"Wisconsin" => "WI",
    	"Wyoming" => "WY",
      "British Columbia" => "BC",
      "Ontario" => "ON",
      "Newfoundland and Labrador" => "NL",
      "Northwest Territories" => "NT",
      "Nova Scotia" => "NS",
      "Prince Edward Island" => "PE",
      "New Brunswick" => "NB",
      "Quebec" => "QC",
      "Manitoba" => "MB",
      "Saskatchewan" => "SK",
      "Alberta" => "AB",
      "Nunavut" => "NU",
      "Yukon" => "YT",
      "Unknown Territory" => "ZZ",
      "Country is Known But Not U.S. Or Canada" => "XX"
    }
    if literal
      return term[0...[28, term.length].min]
    end
    if territories_hash.key?(term)
      return territories_hash[term]
    elsif record_hash.key?(country_key)
      if record_hash[country_key] == "United States" || record_hash[country_key] == "Canada"
        return territories_hash["Unknown Territory"]
      else
        return territories_hash["Country is Known But Not U.S. Or Canada"]
      end
    elsif state_key.include?("locationOfDeath")
      return ""
    else
      return territories_hash["Unknown Territory"]
    end
  end

  # Function that will obtain the code for the sex of the decedent.
  def self.sex_lookup(record_hash, key)
    term = "Unknown"
    if record_hash.key?(key)
      term = record_hash[key]
    end
    sex_hash =
    {
      "Male" => 'M',
      "Female" => 'F',
      "Unknown" => 'U'
    }
    if sex_hash.key?(term)
      return sex_hash[term]
    else
      return "U"
    end
  end

  # Function that will obtain the appropriate code for parameters that require a Y for Yes, N for No, and U for Unknown.
  def self.yes_no_lookup(record_hash, key)
    term = ""
    if record_hash.key?(key)
      term = record_hash[key]
    end
    yes_no_hash =
    {
      "Yes" => 'Y',
      "No" => 'N',
      "Probably" => 'P',
      "Unknown" => 'U',
      "" => 'U'
    }
    return yes_no_hash[term]
  end

  # Function to obtain the appropriate code based on age type.
  def self.age_type_lookup(term)
    age_type =
    {
      "Years" => "1",
      "Months" => "2",
      "Days" => "4",
      "Hours" => "5",
      "Minutes" => "6",
      "Unknown" => "9"
    }
    return age_type[term]
  end

  # Function to obtain the appropriate code for the specified age unit.
  def self.age_units_lookup(term)
    age_units =
    {
      "1" => "001-135, 999",
      "2" => "001-011, 999",
      "4" => "001-027, 999",
      "5" => "001-023, 999",
      "6" => "001-059, 999",
      "9" => "999"
    }
    return age_units[term]
  end

  # Function that will lookup the appropriate code for the place where death occured.
  def self.death_occurrence_lookup(record_hash, key)
    term = ""
    if record_hash.key?(key)
      term = record_hash[key]
    end
    place_death_hash =
    {
      "Inpatient" => "1",
      "Outpatient/ER" => "2",
      "DOA" => "3",
      "Decedent's Home" => "4",
      "Hospice Facility" => "5",
      "Nursing Home/Long Term Care Facility" => "6"
    }
    if !place_death_hash.key?(term)
      return "7"
    else
      return place_death_hash[term]
    end
  end

  # Function that will obtain the appropriate code for highest degree of education completed by decedent.
  def self.education_lookup(record_hash, key)
    term = "Unknown"
    if record_hash.key?(key)
      term = record_hash[key]
    end
    education_hash =
    {
      "8th grade or less" => "1",
      "9th - 12th grade, no diploma" => "2",
      "High school graduate or GED completed" => "3",
      "Some college credit, but no degree" => "4",
      "Associate's degree" => "5",
      "Bachelor's degree" => "6",
      "Master's degree" => "7",
      "Doctorate or Professional degree" => "8",
      "Refused" => "9",
      "Not Obtainable" => "9",
      "Unknown" => "9",
      "Not Classifiable" => "9"
    }
    if education_hash.key?(term)
      return education_hash[term]
    end
      return "9"
  end

  # Function that will get the appropriate code for a country.
  def self.country_lookup(record_hash, key)
    term = ""
    # Check to see if the hash contains the country as a key.
    if record_hash.key?(key)
      term = record_hash[key].upcase
    end
    countries_hash = {
      "AFGHANISTAN"=>"AF",
      "AKROTIRI"=>"AX",
      "ÅLAND"=>"FI",
      "ALBANIA"=>"AL",
      "ALGERIA"=>"AG",
      "ANDORRA"=>"AN",
      "ANGOLA"=>"AO",
      "ANGUILLA"=>"AV",
      "ANTARCTICA"=>"AY",
      "ANTIGUA AND BARBUDA"=>"AC",
      "ARGENTINA"=>"AR",
      "ARMENIA"=>"AM",
      "ARUBA"=>"AA",
      "ASHMORE AND CARTIER ISLANDS"=>"AT",
      "AUSTRALIA"=>"AS", "AUSTRIA"=>"AU",
      "AZERBAIJAN"=>"AJ",
      "AZORES"=>"PO",
      "BAHAMAS"=>"BF",
      "BAHRAIN"=>"BA",
      "BANGLADESH"=>"BG",
      "BARBADOS"=>"BB",
      "BASSAS DA INDIA"=>"BS",
      "BELARUS"=>"BO",
      "BELGIUM"=>"BE",
      "BELIZE"=>"BH",
      "BENIN"=>"BN",
      "BERMUDA"=>"BD",
      "BHUTAN"=>"BT",
      "BOLIVIA"=>"BL",
      "BONAIRE"=>"NL",
      "BOSNIA AND HERZEGOVINA"=>"BK",
      "BOTSWANA"=>"BC",
      "BOUVET ISLAND"=>"BV",
      "BRAZIL"=>"BR",
      "BRITISH INDIAN OCEAN TERRITORY"=>"IO",
      "BRITISH VIRGIN ISLANDS"=>"VI",
      "BRUNEI"=>"BX",
      "BULGARIA"=>"BU",
      "BURKINA FASO"=>"UV",
      "BURMA"=>"BM",
      "BURUNDI"=>"BY",
      "CAMBODIA"=>"CB",
      "CAMEROON"=>"CM",
      "CANADA"=>"CA",
      "CAPE VERDE"=>"CV",
      "CAYMAN ISLANDS"=>"CJ",
      "CENTRAL AFRICAN REPUBLIC"=>"CT",
      "CHAD"=>"CD",
      "CHILE"=>"CI",
      "CHINA"=>"CH",
      "CHRISTMAS ISLAND"=>"KT",
      "CLIPPERTON ISLAND"=>"IP",
      "COCOS (KEELING) ISLANDS"=>"CK",
      "COLOMBIA"=>"CO",
      "COMOROS"=>"CN",
      "CONGO (BRAZZAVILLE)"=>"CF",
      "CONGO (KINSHASA)"=>"CG",
      "COOK ISLANDS"=>"CW",
      "CORAL SEA ISLANDS"=>"CR",
      "COSTA RICA"=>"CS",
      "CÔTE D’IVOIRE"=>"IV",
      "CROATIA"=>"HR",
      "CUBA"=>"CU",
      "CURAÇAO"=>"UC",
      "CYPRUS"=>"CY",
      "CZECH REPUBLIC"=>"EZ",
      "DAHOMEY"=>"DM",
      "DEMOCRATIC REPUBLIC OF THE CONGO"=>"CG",
      "DENMARK"=>"DA",
      "DHEKELIA"=>"DX",
      "DJIBOUTI"=>"DJ",
      "DOMINICA"=>"DO",
      "DOMINICAN REPUBLIC"=>"DR",
      "EAST TIMOR"=>"TT",
      "ECUADOR"=>"EC",
      "EGYPT"=>"EG",
      "EL SALVADOR"=>"ES",
      "ENGLAND"=>"UK",
      "EQUATORIAL GUINEA"=>"EK",
      "ERITREA"=>"ER",
      "ESTONIA"=>"EN",
      "ETHIOPIA"=>"ET",
      "ETOROFU"=>"PJ",
      "HABOMAI"=>"PJ",
      "KUNASHIRI"=>"PJ",
      "SHIKOTAN ISLANDS"=>"PJ",
      "EUROPA ISLAND"=>"EU",
      "FALKLAND ISLANDS"=>"FK",
      "FAROE ISLANDS"=>"FO",
      "FEDERATED STATES OF MICRONESIA"=>"FM",
      "FIJI"=>"FJ",
      "FINLAND"=>"FI",
      "FRANCE"=>"FR",
      "FRENCH GUIANA"=>"FG",
      "FRENCH POLYNESIA"=>"FP",
      "FRENCH SOUTHERN AND ANTARCTIC LANDS"=>"FS",
      "GABON"=>"GB",
      "GAMBIA"=>"GA",
      "GAZA STRIP"=>"GZ",
      "GEORGIA"=>"GG",
      "GERMANY"=>"GM",
      "GHANA"=>"GH",
      "GIBRALTAR"=>"GI",
      "GLORIOSO ISLANDS"=>"GO",
      "GREAT BRITAIN"=>"UK",
      "GREECE"=>"GR",
      "GREENLAND"=>"GL",
      "GRENADA"=>"GJ",
      "GUADELOUPE"=>"GP",
      "GUATEMALA"=>"GT",
      "GUERNSEY"=>"GK",
      "GUINEA"=>"GV",
      "GUINEA-BISSAU"=>"PU",
      "GUYANA"=>"GY",
      "HAITI"=>"HA",
      "HEARD ISLAND AND MCDONALD ISLANDS"=>"HM",
      "HOLY SEE"=>"VT",
      "HONDURAS"=>"HO",
      "HONG KONG"=>"HK",
      "HOWLAND ISLAND"=>"HQ",
      "HUNGARY"=>"HU",
      "ICELAND"=>"IC",
      "INDIA"=>"IN",
      "INDONESIA"=>"ID",
      "IRAN"=>"IR",
      "IRAQ"=>"IZ",
      "IRELAND"=>"EI",
      "ISLAS MALVINAS"=>"FK",
      "ISLE OF MAN"=>"IM",
      "ISRAEL"=>"IS",
      "ITALY"=>"IT",
      "IVORY COAST"=>"IV",
      "JAMAICA"=>"JM",
      "JAN MAYEN"=>"JN",
      "JAPAN"=>"JA",
      "JARVIS ISLAND"=>"DQ",
      "JERSEY"=>"JE",
      "JOHNSTON ISLAND"=>"JQ",
      "JORDAN"=>"JO",
      "JUAN DE NOVA ISLAND"=>"JU",
      "KAZAKHSTAN"=>"KZ",
      "KENYA"=>"KE",
      "KIRIBATI"=>"KR",
      "South Korea"=>"KS",
      "KOSOVO"=>"KV",
      "KUWAIT"=>"KU",
      "KYRGYZSTAN"=>"KG",
      "LAOS"=>"LA",
      "LATVIA"=>"LG",
      "LEBANON"=>"LE",
      "LESOTHO"=>"LT",
      "LIBERIA"=>"LI",
      "LIBYA"=>"LY",
      "LIECHTENSTEIN"=>"LS",
      "LITHUANIA"=>"LH",
      "LUXEMBOURG"=>"LU",
      "MACAU"=>"MC",
      "MACEDONIA"=>"MK",
      "MADAGASCAR"=>"MA",
      "MALAWI"=>"MI",
      "MALAYSIA"=>"MY",
      "MALDIVES"=>"MV",
      "MALI"=>"ML",
      "MALTA"=>"MT",
      "MARSHALL ISLANDS"=>"RM",
      "MARTINIQUE"=>"MB",
      "MAURITANIA"=>"MR",
      "MAURITIUS"=>"MP",
      "MAYOTTE"=>"MF",
      "MEXICO"=>"MX",
      "MIDWAY ISLAND"=>"MQ",
      "MOLDOVA"=>"MD",
      "MONACO"=>"MN",
      "MONGOLIA"=>"MG",
      "MONTENEGRO"=>"MJ",
      "MONTSERRAT"=>"MH",
      "MOROCCO"=>"MO",
      "MOZAMBIQUE"=>"MZ",
      "MYANMAR"=>"BM",
      "NAMIBIA"=>"WA",
      "NAURU"=>"NR",
      "NEPAL"=>"NP",
      "NETHERLANDS"=>"NL",
      "NEVIS"=>"SC",
      "NEW CALEDONIA"=>"NC",
      "NEW HEBRIDES"=>"NH",
      "NEW ZEALAND"=>"NZ",
      "NICARAGUA"=>"NU",
      "NIGER"=>"NG",
      "NIGERIA"=>"NI",
      "NIUE"=>"NE",
      "NORFOLK ISLAND"=>"NF",
      "NORTH KOREA"=>"KN",
      "NORWAY"=>"NO",
      "OMAN"=>"MU",
      "PAKISTAN"=>"PK",
      "PALAU"=>"PS",
      "PALMYRA ATOLL"=>"LQ",
      "PANAMA"=>"PM",
      "PAPUA NEW GUINEA"=>"PP",
      "PARACEL ISLANDS"=>"PF",
      "PARAGUAY"=>"PA",
      "PERU"=>"PE",
      "PHILIPPINES"=>"RP",
      "PITCAIRN ISLAND"=>"PC",
      "POLAND"=>"PL",
      "PORTUGAL"=>"PO",
      "QATAR"=>"QA",
      "REPUBLIC OF THE CONGO"=>"CF",
      "REUNION"=>"RE",
      "ROMANIA"=>"RO",
      "RUSSIA"=>"RS",
      "RWANDA"=>"RW",
      "SABA"=>"NL",
      "SAINT BARTHÉLEMY"=>"TB",
      "SAINT EUSTATIUS"=>"NL",
      "SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA"=>"SH",
      "SAINT KITTS AND NEVIS"=>"SC",
      "SAINT LUCIA"=>"ST",
      "SAINT MARTIN"=>"RN",
      "SAINT PIERRE AND MIQUELON"=>"SB",
      "SAINT VINCENT AND THE GRENADINES"=>"VC",
      "SAMOA"=>"WS",
      "SAN MARINO"=>"SM",
      "SAO TOME AND PRINCIPE"=>"TP",
      "SAUDI ARABIA"=>"SA",
      "SENEGAL"=>"SG",
      "SERBIA"=>"RI",
      "SEYCHELLES"=>"SE",
      "SIERRA LEONE"=>"SL",
      "SINGAPORE"=>"SN",
      "SINT MAARTEN"=>"NN",
      "SLOVAKIA"=>"LO",
      "SLOVENIA"=>"SI",
      "SOLOMON ISLANDS"=>"BP",
      "SOMALIA"=>"SO",
      "SOUTH AFRICA"=>"SF",
      "SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS"=>"SX",
      "SOUTH KOREA"=>"KS",
      "SOUTH SUDAN"=>"OD",
      "SPAIN"=>"SP",
      "SPRATLY ISLANDS"=>"PG",
      "SRI LANKA"=>"CE",
      "SUDAN"=>"SU",
      "SURINAME"=>"NS",
      "SVALBARD"=>"SV",
      "SWAZILAND"=>"WZ",
      "SWEDEN"=>"SW",
      "SWITZERLAND"=>"SZ",
      "SYRIA"=>"SY",
      "TAHITI"=>"FP",
      "TAIWAN"=>"TW",
      "TAJIKISTAN"=>"TI",
      "TANZANIA"=>"TZ",
      "THAILAND"=>"TH",
      "TIMOR-LESTE"=>"TT",
      "TOGO"=>"TO",
      "TOKELAU"=>"TL",
      "TONGA"=>"TN",
      "TRINIDAD AND TOBAGO"=>"TD",
      "TROMELIN ISLAND"=>"TE",
      "TUNISIA"=>"TS",
      "TURKEY"=>"TU",
      "TURKMENISTAN"=>"TX",
      "TURKS AND CAICOS ISLANDS"=>"TK",
      "TUVALU"=>"TV",
      "UGANDA"=>"UG",
      "UKRAINE"=>"UP",
      "UNITED ARAB EMIRATES"=>"AE",
      "UNITED KINGDOM"=>"UK",
      "UNITED STATES"=>"US",
      "UPPER VOLTA"=>"UV",
      "URUGUAY"=>"UY",
      "UZBEKISTAN"=>"UZ",
      "VANUATU"=>"NH",
      "VATICAN CITY"=>"VT",
      "VENEZUELA"=>"VE",
      "VIETNAM"=>"VM",
      "WAKE ISLAND"=>"WQ",
      "WALLIS AND FUTUNA"=>"WF",
      "WEST BANK"=>"WE",
      "WESTERN SAHARA"=>"WI",
      "YEMEN"=>"YM",
      "ZAIRE"=>"CG",
      "ZAMBIA"=>"ZA",
      "ZIMBABWE"=>"ZI",
      "NOT CLASSIFIABLE"=>"ZZ"
    }
    if countries_hash.key?(term)
      return countries_hash[term]
    end
    return "ZZ"
  end


  # Take in an array of hashes where each hash represents a Nightingale record and create a list of strings of the corresponding IJE format.
  def self.process_data(record_hash)
    record_hash.each do |record|
      record = IJE::MortalityFormat.new(date_of_death_year: IJEFormat.extract_date(record, "datePronouncedDead.datePronouncedDead", "year"),
                                          state_territory_province_code: IJEFormat.territory_lookup(record, "locationOfDeath.state", "locationOfDeath.city", "locationOfDeath.country"),
                                          certificate_number: "",
                                          void_flag: 0,
                                          auxiliary_state_file_number: "",
                                          source_flag: 0,
                                          decedant_legal_name_given: IJEFormat.lookup(record, "decedentName.firstName", 50),
                                          decedant_legal_name_middle: IJEFormat.lookup(record, "decedentName.middleName", 1),
                                          decedant_legal_name_last: IJEFormat.lookup(record, "decedentName.lastName", 50),
                                          decedant_legal_name_suffix: IJEFormat.lookup(record, "decedentName.suffix", 10),
                                          decedant_legal_name_alias: 0,
                                          father_surname: IJEFormat.lookup(record, "fatherName.last_name", 50),
                                          sex: IJEFormat.sex_lookup(record, "sex.sex"),
                                          sex_edit_flag: 0,
                                          social_security_number: obtain_ssn(record),
                                          decedents_age_type: "",
                                          decedents_age_units: "",
                                          decedents_age_edit_flag: "",
                                          date_of_birth_year: IJEFormat.extract_date(record, "dateOfBirth.dateOfBirth", "year"),
                                          date_of_birth_month: IJEFormat.extract_date(record,"dateOfBirth.dateOfBirth", "month"),
                                          date_of_birth_day: IJEFormat.extract_date(record,"dateOfBirth.dateOfBirth", "day"),
                                          birthplace_country: IJEFormat.country_lookup(record, "placeOfBirth.country"),
                                          state_us_territory_or_canadian_province_of_birth_code: IJEFormat.territory_lookup(record, "placeOfBirth.state", "placeOfBirth.city", "placeOfBirth.country"),
                                          decedents_residence_city: IJEFormat.lookup(record, "decedentAddress.zip", 9),
                                          decedents_residence_county: "",
                                          state_us_territory_or_canadian_province_of_decedents_residence_code: IJEFormat.territory_lookup(record, "decedentAddress.state", "decedentAddress.city", "decedentAddress.country"),
                                          decedents_residence_country: "US",
                                          decedents_residence_inside_city_limits: "",
                                          marital_status: IJEFormat.marriage_lookup(record, "maritalStatus.maritalStatus"),
                                          marital_status_edit_flag: IJEFormat.edit_flag_lookup("Edit Passed"),
                                          place_of_death: IJEFormat.death_occurrence_lookup(record, "placeOfDeath.placeOfDeath.option"),
                                          county_of_death_occurrence: "",
                                          method_of_disposition: IJEFormat.disposition_lookup(record, "methodOfDisposition.methodOfDisposition.option"),
                                          date_of_death_month: IJEFormat.extract_date(record,"dateOfDeath.dateOfDeath", "month"),
                                          date_of_death_day: IJEFormat.extract_date(record,"dateOfDeath.dateOfDeath", "day"),
                                          time_of_death: IJEFormat.extract_date(record,"timeOfDeath.timeOfDeath", "time"),
                                          decedents_education: IJEFormat.education_lookup(record, "education.education"),
                                          decedents_education_edit_flag: IJEFormat.edit_flag_lookup("Edit Passed"),
                                          decedent_of_hispanic_origin_mexican: IJEFormat.hispanic_origin_lookup(record, "Mexican, Mexican American, Chicano"),
                                          decedent_of_hispanic_origin_puerto_rican:  IJEFormat.hispanic_origin_lookup(record, "Puerto Rican"),
                                          decedent_of_hispanic_origin_cuban: IJEFormat.hispanic_origin_lookup(record, "Cuban"),
                                          decedent_of_hispanic_origin_other: IJEFormat.hispanic_origin_lookup(record, "Other Spanish/Hispanic/Latino (specify)"),
                                          decedent_of_hispanic_origin_other_literal: IJEFormat.extract_other(record, "hispanicOrigin.hispanicOrigin.specifyInputs", "Other Spanish/Hispanic/Latino (specify)", 20),
                                          decedents_race_white: IJEFormat.race_lookup(record, "race.race.specify", "White"),
                                          decedents_race_black_or_african_american: IJEFormat.race_lookup(record, "race.race.specify", "Black or African America"),
                                          decedents_race_american_indian_or_alaska_native: IJEFormat.race_lookup(record, "race.race.specify", "American Indian or Alaskan Native (specify tribe)"),
                                          decedents_race_asian_indian: IJEFormat.race_lookup(record, "race.race.specify", "Asian Indian"),
                                          decedents_race_chinese: IJEFormat.race_lookup(record, "race.race.specify", "Chinese"),
                                          decedents_race_filipino: IJEFormat.race_lookup(record, "race.race.specify", "Filipino"),
                                          decedents_race_japanese: IJEFormat.race_lookup(record, "race.race.specify", "Japanese"),
                                          decedents_race_korean: IJEFormat.race_lookup(record, "race.race.specify", "Korean"),
                                          decedents_race_vietnamese: IJEFormat.race_lookup(record, "race.race.specify", "Vietnamese"),
                                          decedents_race_other_asian: IJEFormat.race_lookup(record, "race.race.specify", "Other Asian (specify)"),
                                          decedents_race_native_hawaiian: IJEFormat.race_lookup(record, "race.race.specify", "Native Hawaiian"),
                                          decedents_race_guamanian_or_chamorro: IJEFormat.race_lookup(record, "race.race.specify", "Guamanian or Chamorro"),
                                          decedents_race_samoan: IJEFormat.race_lookup(record, "race.race.specify", "Samoan"),
                                          decedents_race_other_pacific_islander: IJEFormat.race_lookup(record, "race.race.specify", "Other Pacific Islander (specify)"),
                                          decedents_race_other: IJEFormat.race_lookup(record, "race.race.specify", "Other (specify)"),
                                          decedents_race_first_american_indian_or_alaska_native_literal: IJEFormat.decedent_literal_lookup(record, "race.race.specifyInputs", "American Indian or Alaskan Native (specify tribe)"),
                                          decedents_race_second_american_indian_or_alaska_native_literal: "",
                                          decedents_race_first_other_asian_literal: IJEFormat.decedent_literal_lookup(record, "race.race.specifyInputs", "Other Asian (specify)"),
                                          decedents_race_second_other_asian_literal: "",
                                          decedents_race_first_other_pacific_islander_literal: IJEFormat.decedent_literal_lookup(record, "race.race.specifyInputs", "Other Pacific Islander (specify)"),
                                          decedents_race_second_other_pacific_islander_literal: "",
                                          decedents_race_first_other_literal: IJEFormat.decedent_literal_lookup(record, "race.race.specifyInputs", "Other (specify)"),
                                          decedents_race_second_other_literal: "",
                                          race_tabulation_variables: "",
                                          race_tabulation_variables_second: "",
                                          race_tabulation_variables_third: "",
                                          race_tabulation_variables_fourth: "",
                                          race_tabulation_variables_fifth: "",
                                          race_tabulation_variables_sixth: "",
                                          race_tabulation_variables_seventh: "",
                                          race_tabulation_variables_eighth: "",
                                          race_tabulation_variables_ninth: "",
                                          race_tabulation_variables_tenth: "",
                                          race_tabulation_variables_eleventh: "",
                                          race_tabulation_variables_twelvth: "",
                                          race_tabulation_variables_thirteenth: "",
                                          race_tabulation_variables_fourteenth: "",
                                          race_tabulation_variables_fifteenth: "",
                                          race_tabulation_variables_sixteenth: "",
                                          occupation_literal_optional: IJEFormat.lookup(record, "usualOccupation.usualOccupation", 40),
                                          occupation_code_optional: "",
                                          industry_literal_optional: IJEFormat.lookup(record, "kindOfBusiness.kindOfBusiness", 40),
                                          industry_code_optional: "",
                                          infant_death_birth_linking_birth_certificate_number: "",
                                          infant_death_birth_linking_year_of_birth: IJEFormat.extract_date(record, "datePronouncedDead.datePronouncedDead", "year"),
                                          infant_death_birth_linking_state_us_territory_or_canadian_province_of_birth_code: IJEFormat.territory_lookup(record, "locationOfDeath.state", "locationOfDeath.city", "locationOfDeath.country"),
                                          receipt_date_year: "",
                                          receipt_date_month: "",
                                          receipt_date_day: "",
                                          filler_1_for_expansion: "",
                                          date_of_registration_year: "",
                                          date_of_registration_month: "",
                                          date_of_registration_day: "",
                                          filler_2_for_expansion: "",
                                          manner_of_death: IJEFormat.manner_of_death_lookup(record, "mannerOfDeath.mannerOfDeath"),
                                          intentional_reject_: "",
                                          acme_system_reject_codes: "",
                                          place_of_injury_computer_generated: "",
                                          manual_underlying_cause_: "",
                                          acme_underlying_cause: "",
                                          entity_axis_codes: "",
                                          transax_conversion_flag_computer_generated: "",
                                          record_axis_codes: "",
                                          was_autopsy_performed: IJEFormat.yes_no_lookup(record, "autopsyPerformed.autopsyPerformed"),
                                          were_autopsy_findings_available_to_complete_the_cause_of_death: IJEFormat.yes_no_lookup(record, "autopsyAvailableToCompleteCauseOfDeath.autopsyAvailableToCompleteCauseOfDeath"),
                                          did_tobacco_use_contribute_to_death: IJEFormat.yes_no_lookup(record, "didTobaccoUseContributeToDeath.didTobaccoUseContributeToDeath"),
                                          pregnancy: IJEFormat.pregnancy_lookup(record, "pregnancyStatus.pregnancyStatus"),
                                          if_female_edit_flag_from_edr_only: "",
                                          date_of_injury_month: "",
                                          date_of_injury_day: "",
                                          date_of_injury_year: "",
                                          time_of_injury: "",
                                          injury_at_work: "",
                                          title_of_certifier: IJEFormat.certifier_lookup(record, "certifierType.certifierType", 30),
                                          activity_at_time_of_death_computer_generated: "",
                                          auxiliary_state_file_number_second: "",
                                          state_specific_data_: "",
                                          surgery_date_month: "",
                                          surgery_date_day: "",
                                          surgery_date_year: "",
                                          time_of_injury_unit: "",
                                          for_possible_future_change_in_transax: "",
                                          decedent_ever_served_in_armed_forces: IJEFormat.yes_no_lookup(record, "armedForcesService.armedForcesService"),
                                          death_institution_name: IJEFormat.death_place_lookup(record, "placeOfDeath.placeOfDeath.option", "placeOfDeath.placeOfDeath.specifyInputs"),
                                          long_string_address_for_place_of_death: IJEFormat.lookup(record, "locationOfDeath.street", 50),
                                          place_of_death_street_number: IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "number"),
                                          place_of_death_pre_directional: IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "prefix"),
                                          place_of_death_street_name: IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "street"),
                                          place_of_death_street_designator: IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "street_type"),
                                          place_of_death_post_directional: IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "suffix"),
                                          place_of_death_city_or_town_name: IJEFormat.lookup(record, "locationOfDeath.city", 28),
                                          place_of_death_state_name_literal: IJEFormat.territory_lookup(record, "locationOfDeath.state", "locationOfDeath.city", "locationOfDeath.country", true),
                                          place_of_death_zip_code: IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "zip"),
                                          place_of_death_county_of_death: IJEFormat.lookup(record, "locationOfDeath.county", 28),
                                          place_of_death_city_fips_code: "",
                                          place_of_death_longitude: "", #IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "longitude"),
                                          place_of_death_latitude: "", #IJEFormat.parse_street(record, "locationOfDeath.street", "locationOfDeath.city", "locationOfDeath.state", "locationOfDeath.zip", "latitude"),
                                          decedents_spouse_living_at_decedents_dod: IJEFormat.check_if_spouse_alive(record, "maritalStatus.maritalStatus"),
                                          spouses_first_name: IJEFormat.lookup(record, "spouseName.firstName", 50),
                                          husbands_surname_wifes_maiden_last_name: IJEFormat.lookup(record, "spouseName.lastName", 50),
                                          decedents_residence_street_number: IJEFormat.parse_street(record, "decedentAddress.street", "decedentAddress.city", "decedentAddress.state", "decedentAddress.zip", "number"),
                                          decedents_residence_pre_directional: IJEFormat.parse_street(record, "decedentAddress.street", "decedentAddress.city", "decedentAddress.state", "decedentAddress.zip", "prefix"),
                                          decedents_residence_street_name: IJEFormat.parse_street(record, "decedentAddress.street", "decedentAddress.city", "decedentAddress.state", "decedentAddress.zip", "street"),
                                          decedents_residence_street_designator: IJEFormat.parse_street(record, "decedentAddress.street", "decedentAddress.city", "decedentAddress.state", "decedentAddress.zip", "street_type"),
                                          decedents_residence_post_directional: IJEFormat.parse_street(record, "decedentAddress.street", "decedentAddress.city", "decedentAddress.state", "decedentAddress.zip", "suffix"),
                                          decedents_residence_unit_or_apt_number: IJEFormat.lookup(record, "decedentAddress.apt", 7),
                                          decedents_residence_city_or_town_name: IJEFormat.lookup(record, "decedentAddress.city", 28),
                                          decedents_residence_zip_code: IJEFormat.parse_street(record, "decedentAddress.street", "decedentAddress.city", "decedentAddress.state", "decedentAddress.zip", "zip"),
                                          decedents_residence_county_second: IJEFormat.lookup(record, "decedentAddress.county", 28),
                                          decedents_residence_state_name: IJEFormat.territory_lookup(record, "decedentAddress.state", "decedentAddress.city", "decedentAddress.country", true),
                                          decedents_residence_country_name: "",
                                          long_string_address_for_decedents_place_of_residence_: IJEFormat.lookup(record, "decedentAddress.street", 50),
                                          old_nchs_residence_state_code: IJEFormat.territory_lookup(record, "decedentAddress.state", "decedentAddress.city", "decedentAddress.country"),
                                          old_nchs_residence_city_county_combo_code: "",
                                          hispanic_nchs_will_send_this_information_to_occurrence_state: IJEFormat.hispanic_nchs_lookup(record),
                                          race_this_item_will_be_returned_to_occurrence_state: IJEFormat.race_code_lookup(record, "race.race.specify"),
                                          hispanic_old_nchs_single_ethnicity_codes: IJEFormat.prior_nchs_hispanic_lookup(record),
                                          race_old_nchs_single_race_codes: IJEFormat.prior_nchs_race_lookup(record, "race.race.specify"),
                                          hispanic_origin_specify: "",
                                          race_specify: "",
                                          middle_name_of_decedent: IJEFormat.lookup(record, "decedentName.middleName", 50),
                                          fathers_first_name: IJEFormat.lookup(record, "fatherName.firstName", 50),
                                          fathers_middle_name: IJEFormat.lookup(record, "fatherName.middleName", 50),
                                          mothers_first_name: IJEFormat.lookup(record, "motherName.firstName", 50),
                                          mothers_middle_name: IJEFormat.lookup(record, "motherName.middleName", 50),
                                          mothers_maiden_surname: IJEFormat.lookup(record, "motherName.lastName", 50),
                                          was_case_referred_to_medical_examiner_coroner: "",
                                          place_of_injury_literal: "",
                                          describe_how_injury_occurred: "",
                                          if_transportation_accident_specify: "",
                                          county_of_injury_literal: "",
                                          county_of_injury_code: "",
                                          town_city_of_injury_literal: "",
                                          town_city_of_injury_code: "",
                                          state_us_territory_or_canadian_province_of_injury_code: "",
                                          place_of_injury_longitude: "",
                                          place_of_injury_latitude: "",
                                          old_nchs_education_code: "",
                                          replacement_record___suggested_codes: "",
                                          cause_of_death_part_i_line_a: IJEFormat.lookup(record, "cod.immediate", 120),
                                          cause_of_death_part_i_interval_line_a: IJEFormat.lookup(record, "cod.immediateInt", 20),
                                          cause_of_death_part_i_line_b: IJEFormat.lookup(record, "cod.under1", 120),
                                          cause_of_death_part_i_interval_line_b: IJEFormat.lookup(record, "cod.under1Int", 20),
                                          cause_of_death_part_i_line_c: IJEFormat.lookup(record, "cod.under2", 120),
                                          cause_of_death_part_i_interval_line_c: IJEFormat.lookup(record, "cod.under2Int", 20),
                                          cause_of_death_part_i_line_d: IJEFormat.lookup(record, "cod.under3", 120),
                                          cause_of_death_part_i_interval_line_d: IJEFormat.lookup(record, "cod.under3Int", 20),
                                          cause_of_death_part_ii: "",
                                          decedents_maiden_name: "",
                                          decedents_birth_place_city___code: "",
                                          decedents_birth_place_city___literal: IJEFormat.lookup(record, "placeOfBirth.city", 28),
                                          spouses_middle_name: IJEFormat.lookup(record, "spouseName.middleName", 10),
                                          spouses_suffix: IJEFormat.lookup(record, "spouseName.suffix", 10),
                                          fathers_suffix: IJEFormat.lookup(record, "fatherName.suffix", 10),
                                          mothers_suffix: IJEFormat.lookup(record, "motherName.suffix", 10),
                                          informants_relationship: "",
                                          state_us_territory_or_canadian_province_of_disposition_code: IJEFormat.territory_lookup(record, "placeOfDisposition.state", "placeOfDisposition.city", "placeOfDisposition.country"),
                                          disposition_state_or_territory_literal: IJEFormat.territory_lookup(record, "placeOfDisposition.state", "placeOfDisposition.city", "placeOfDisposition.country", true),
                                          disposition_city_code: "",
                                          disposition_city_literal: IJEFormat.lookup(record, "placeOfDisposition.city", 28),
                                          funeral_facility_name: IJEFormat.lookup(record, "funeralFacility.name", 100),
                                          funeral_facility_street_number: IJEFormat.parse_street(record, "funeralFacility.street", "funeralFacility.city", "funeralFacility.state", "funeralFacility.zip", "number"),
                                          funeral_facility_pre_directional: IJEFormat.parse_street(record, "funeralFacility.street", "funeralFacility.city", "funeralFacility.state", "funeralFacility.zip", "prefix"),
                                          funeral_facility_street_name: IJEFormat.parse_street(record, "funeralFacility.street", "funeralFacility.city", "funeralFacility.state", "funeralFacility.zip", "street"),
                                          funeral_facility_street_designator: IJEFormat.parse_street(record, "funeralFacility.street", "funeralFacility.city", "funeralFacility.state", "funeralFacility.zip", "street_type"),
                                          funeral_facility_post_directional: IJEFormat.parse_street(record, "funeralFacility.street", "funeralFacility.city", "funeralFacility.state", "funeralFacility.zip", "suffix"),
                                          funeral_facility_unit_or_apt_number: IJEFormat.lookup(record, "funeralFacility.apt", 7),
                                          long_string_address_for_funeral_facility: IJEFormat.lookup(record, "funeralFacility.street", 50),
                                          funeral_facility_city_or_town_name: IJEFormat.lookup(record, "funeralFacility.city", 28),
                                          state_us_territory_or_canadian_province_of_funeral_facility_code: IJEFormat.territory_lookup(record, "funeralFacility.state", "funeralFacility.city", "funeralFacility.country"),
                                          state_us_territory_or_canadian_province_of_funeral_facility_literal: IJEFormat.territory_lookup(record, "funeralFacility.state", "funeralFacility.city", "funeralFacility.country", true),
                                          funeral_facility_zip: IJEFormat.lookup(record, "funeralFacility.zip", 9),
                                          person_pronouncing_date_signed: IJEFormat.extract_date(record,"dateOfPronouncerSignature.dateOfPronouncerSignature", "format"),
                                          person_pronouncing_time_pronounced: IJEFormat.extract_date(record, "timePronouncedDead.timePronouncedDead", "time"),
                                          certifiers_first_name: IJEFormat.lookup(record, "personCompletingCauseOfDeathName.firstName", 50),
                                          certifiers_middle_name: IJEFormat.lookup(record, "personCompletingCauseOfDeathName.middleName", 50),
                                          certifiers_last_name: IJEFormat.lookup(record, "personCompletingCauseOfDeathName.lastName", 50),
                                          certifiers_suffix_name: IJEFormat.lookup(record, "personCompletingCauseOfDeathName.suffix", 10),
                                          certifier_street_number: IJEFormat.parse_street(record, "personCompletingCauseOfDeathAddress.street", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.zip", "number"),
                                          certifier_pre_directional: IJEFormat.parse_street(record, "personCompletingCauseOfDeathAddress.street", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.zip", "number" "prefix"),
                                          certifier_street_name: IJEFormat.parse_street(record, "personCompletingCauseOfDeathAddress.street", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.zip", "number" "street"),
                                          certifier_street_designator: IJEFormat.parse_street(record, "personCompletingCauseOfDeathAddress.street", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.zip", "number" "street_type"),
                                          certifier_post_directional: IJEFormat.parse_street(record, "personCompletingCauseOfDeathAddress.street", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.zip", "number" "suffix"),
                                          certifier_unit_or_apt_number: IJEFormat.lookup(record, "personCompletingCauseOfDeathAddress.apt", 7),
                                          long_string_address_for_certifier: IJEFormat.lookup(record, "personCompletingCauseOfDeathAddress.street", 50),
                                          certifier_city_or_town_name: IJEFormat.lookup(record, "personCompletingCauseOfDeathAddress.city", 28),
                                          state_us_territory_or_canadian_province_of_certifier_code: IJEFormat.territory_lookup(record, "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.country"),
                                          state_us_territory_or_canadian_province_of_certifier_literal: IJEFormat.territory_lookup(record, "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.country", true),
                                          certifier_zip: IJEFormat.parse_street(record, "personCompletingCauseOfDeathAddress.street", "personCompletingCauseOfDeathAddress.city", "personCompletingCauseOfDeathAddress.state", "personCompletingCauseOfDeathAddress.zip", "zip"),
                                          certifier_date_signed: IJEFormat.extract_date(record, "dateCertified.dateCertified", "format"),
                                          date_filed: "",
                                          state_us_territory_or_canadian_province_of_injury_literal: "",
                                          state_us_territory_or_canadian_province_of_birth_literal: IJEFormat.territory_lookup(record, "placeOfBirth.state", "placeOfBirth.city", "placeOfBirth.country", true),
                                          country_of_death_code: "",
                                          country_of_death_literal: "",
                                          ssa_state_source_of_death: "",
                                          ssa_foreign_country_indicator: "",
                                          ssa_edr_verify_code: "",
                                          ssa_date_of_ssn_verification: "",
                                          ssa_date_of_state_transmission: "",
                                          marital_descriptor: "",
                                          hispanic_code_for_literal: "",
                                          blank_for_future_expansion: "",
                                          blank_for_jurisdictional_use_only: ""
                                          )
      result = IJE::MortalityFormat.write([record])
      return result
    end
  end
end
