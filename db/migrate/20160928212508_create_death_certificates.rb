# -*- coding: utf-8 -*-
class CreateDeathCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :death_certificates do |t|

      # This roughly models a death certificate after the U.S. STANDARD CERTIFICATE OF DEATH
      # available here: http://www.cdc.gov/nchs/data/dvs/DEATH11-03final-acc.pdf

      # To Be Completed/ Verified By: FUNERAL DIRECTOR

      # 1. DECEDENT’S LEGAL NAME (Include AKA’s if any) (First, Middle, Last)
      t.string :decedents_legal_name_first, :decedents_legal_name_middle, :decedents_legal_name_last

      # 2. SEX
      t.string :sex

      # 3. SOCIAL SECURITY NUMBER
      t.string :social_security_number

      # 4a. AGE-Last Birthday 4b. UNDER 1 YEAR 4c. UNDER 1 DAY
      # Note: Age is captured at different levels of granularity depending on range
      # TODO: This seems like it can be a derived value, TBD

      # 5. DATE OF BIRTH (Mo/Day/Yr)
      t.date :date_of_birth

      # 6. BIRTHPLACE (City and State or Foreign Country) 
      # TODO: We need to enforce either city and state or country when validating input
      t.string :birthplace_city, :birthplace_state, :birthplace_country

      # 7g. INSIDE CITY LIMITS? Yes / No
      t.boolean :inside_city_limits

      # 8. EVER IN US ARMED FORCES? Yes / No
      t.boolean :ever_in_us_armed_forces

      # 9. MARITAL STATUS AT TIME OF DEATH Married / Married, but separated / Widowed / Divorced / Never Married / Unknown
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :marital_status_at_time_of_death

      # 10. SURVIVING SPOUSE’S NAME (If wife, give name prior to first marriage)
      t.string :surviving_spouses_name

      # 11. FATHER’S NAME (First, Middle, Last)
      t.string :fathers_name_first, :fathers_name_middle, :fathers_name_last

      # 12. MOTHER’S NAME PRIOR TO FIRST MARRIAGE (First, Middle, Last)
      t.string :mothers_name_first, :mothers_name_middle, :mothers_name_last

      # 13a. INFORMANT’S NAME
      t.string :informants_name_first, :informants_name_middle, :informants_name_last

      # 13b. RELATIONSHIP TO DECEDENT
      t.string :informants_relationship_to_decedent

      # 13c. MAILING ADDRESS (Street and Number, City, State, Zip Code)
      t.string :informants_mailing_address_street_and_number, :informants_mailing_address_city, :informants_mailing_address_state,
               :informants_mailing_address_zip_code

      # 14. PLACE OF DEATH (Check only one: see instructions)
      # IF DEATH OCCURRED IN A HOSPITAL: Inpatient / Emergency Room/Outpatient / Dead on Arrival
      # IF DEATH OCCURRED SOMEWHERE OTHER THAN A HOSPITAL: Hospice facility / Nursing home/Long term care facility /
      # Decedent’s home / Other (Specify)
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types (allowing other)
      t.string :place_of_death, :place_of_death_specified

      # 15. FACILITY NAME (If not institution, give street & number)
      t.string :place_of_death_facility_name

      # 16. CITY OR TOWN, STATE, AND ZIP CODE
      t.string :place_of_death_city, :place_of_death_state, :place_of_death_zip_code

      # 17. COUNTY OF DEATH
      t.string :county_of_death

      # 18. METHOD OF DISPOSITION: Burial / Cremation / Donation / Entombment / Removal from State / Other (Specify)
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types (allowing other)
      t.string :method_of_disposition, :method_of_disposition_specified

      # 19. PLACE OF DISPOSITION (Name of cemetery, crematory, other place)
      t.string :place_of_disposition

      # 20. LOCATION-CITY, TOWN, AND STATE
      t.string :place_of_disposition_city, :place_of_disposition_state

      # 21. NAME AND COMPLETE ADDRESS OF FUNERAL FACILITY
      # TODO: We may want to model this as a relationship to a separate funeral_facility
      t.string :funeral_facility_name, :funeral_facility_street_and_number, :funeral_facility_city, :funeral_facility_state,
               :funeral_facility_zip

      # 22. SIGNATURE OF FUNERAL SERVICE LICENSEE OR OTHER AGENT
      # TODO: Need to determine approach for digital signatures (voice, fax, etc)

      # 23. LICENSE NUMBER (Of Licensee)
      # TODO: We may want to model this as a relationship to a separate funeral_director
      t.string :funeral_director_license_number

      # To Be Completed By: MEDICAL CERTIFIER

      # ITEMS 24-28 MUST BE COMPLETED BY PERSON WHO PRONOUNCES OR CERTIFIES DEATH

      # 24. DATE PRONOUNCED DEAD (Mo/Day/Yr)
      t.date :date_pronounced_dead

      # 25. TIME PRONOUNCED DEAD
      # TODO: We may want to combine date and time into a datetime field
      t.time :time_pronounced_dead

      # 26. SIGNATURE OF PERSON PRONOUNCING DEATH (Only when applicable) 
      # TODO: Need to determine approach for digital signatures (voice, fax, etc)

      # 27. LICENSE NUMBER
      # TODO: We may want to model this as a relationship to a separate medical_certifier
      # TODO: We need to be clear on how this is distinct from #48
      t.string :pronouncing_medical_certifier_license_number

      # 28. DATE SIGNED (Mo/Day/Yr)
      t.date :medical_certifier_date_signed

      # 29. ACTUAL OR PRESUMED DATE OF DEATH (Mo/Day/Yr) (Spell Month)
      t.date :actual_or_presumed_date_of_death

      # 30. ACTUAL OR PRESUMED TIME OF DEATH
      # TODO: We may want to combine date and time into a datetime field
      t.time :actual_or_presumed_time_of_death

      # 31. WAS MEDICAL EXAMINER OR CORONER CONTACTED? Yes / No
      t.boolean :was_medical_examiner_or_coroner_contacted

      # 32. CAUSE OF DEATH
      # TODO: We may want to represent this with a relation to a cause_of_death table

      # PART I. Enter the chain of events--diseases, injuries, or complications--that directly caused the
      # death. DO NOT enter terminal events such as cardiac arrest, respiratory arrest, or ventricular
      # fibrillation without showing the etiology. DO NOT ABBREVIATE. Enter only one cause on a line. Add
      # additional lines if necessary.

      # IMMEDIATE CAUSE (Final disease or condition resulting in death)
      t.string :cause_of_death_a

      # Sequentially list conditions, if any, leading to the cause listed on line a. Enter the UNDERLYING
      # CAUSE (disease or injury that initiated the events resulting in death)
      t.string :cause_of_death_b
      t.string :cause_of_death_c
      t.string :cause_of_death_d

      # Approximate interval: Onset to death
      # TODO: We'll start by specifying this in seconds
      t.integer :cause_of_death_approximate_interval_a
      t.integer :cause_of_death_approximate_interval_b
      t.integer :cause_of_death_approximate_interval_c
      t.integer :cause_of_death_approximate_interval_d

      # PART II. Enter other significant conditions contributing to death but not resulting in the underlying cause given in PART I
      t.string :cause_of_death_other_significant_conditions


      # 33. WAS AN AUTOPSY PERFORMED? Yes / No 
      t.boolean :was_an_autopsy_performed

      # 34. WERE AUTOPSY FINDINGS AVAILABLE TO COMPLETE THE CAUSE OF DEATH? Yes / No
      t.boolean :were_autopsy_findings_available

      # 35. DID TOBACCO USE CONTRIBUTE TO DEATH? Yes / Probably / No / Unknown
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :did_tobacco_use_contribute_to_death

      # 36. IF FEMALE: Not pregnant within past year / Pregnant at time of death / Not pregnant, but pregnant within 42 days of death /
      # Not pregnant, but pregnant 43 days to 1 year before death /  Unknown if pregnant within the past year
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :pregnancy_status

      # 37. MANNER OF DEATH Natural / Homicide / Accident / Pending Investigation / Suicide / Could not be determined 
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :manner_of_death

      # 38. DATE OF INJURY (Mo/Day/Yr) (Spell Month)
      t.date :date_of_injury

      # 39. TIME OF INJURY
      # TODO: We may want to combine date and time into a datetime field
      t.time :time_of_injury

      # 40. PLACE OF INJURY (e.g., Decedent’s home; construction site; restaurant; wooded area)
      t.string :place_of_injury

      # 41. INJURY AT WORK? Yes / No
      t.boolean :injury_at_work

      # 42. LOCATION OF INJURY: State, City or Town, Street & Number, Apartment No., Zip Code
      t.string :location_of_injury_state, :location_of_injury_city, :location_of_injury_street_and_number, :location_of_injury_apartment_number,
               :location_of_injury_zip_code

      # 43. DESCRIBE HOW INJURY OCCURRED
      t.string :description_of_injury_occurrence

      # 44. IF TRANSPORTATION INJURY, SPECIFY Driver/Operator / Passenger / Pedestrian / Other (Specify)
      t.boolean :transportation_injury
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types (allowing other)
      t.string :transportation_injury_role, :transportation_injury_role_specified

      # 45. CERTIFIER (Check only one)

      # Certifying physician: To the best of my knowledge, death occurred due to the cause(s) and manner
      # stated.

      # Pronouncing & Certifying physician: To the best of my knowledge, death occurred at the time, date, and
      # place, and due to the cause(s) and manner stated.

      # Medical Examiner/Coroner-On the basis of examination, and/or investigation, in my opinion, death
      # occurred at the time, date, and place, and due to the cause(s) and manner stated.

      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :certifier_type

      # Signature of certifier
      # TODO: Need to determine approach for digital signatures (voice, fax, etc)

      # 46. NAME, ADDRESS, AND ZIP CODE OF PERSON COMPLETING CAUSE OF DEATH (Item 32)
      # TODO: We likely want to model this as a relationship to a separate medical_certifier
      t.string :medical_certifier_first, :medical_certifier_last, :medical_certifier_state, :medical_certifier_city, :medical_certifier_street_and_number,
               :medical_certifier_zip_code

      # 47. TITLE OF CERTIFIER
      # TODO: We likely want to model this as a relationship to a separate medical_certifier
      t.string :medical_certifier_title

      # 48. LICENSE NUMBER
      # TODO: We may want to model this as a relationship to a separate medical_certifier
      # TODO: We need to be clear on how this is distinct from #27
      t.string :medical_certifier_license_number

      # 49. DATE CERTIFIED (Mo/Day/Yr)
      t.date :date_certified

      # 50. FOR REGISTRAR ONLY- DATE FILED (Mo/Day/Yr)
      t.date :date_filed

      # To Be Completed By: FUNERAL DIRECTOR

      # 51. DECEDENT’S EDUCATION: Check the box that best describes the highest degree or level of school
      # completed at the time of death.
      #
      # 8th grade or less
      # 9th - 12th grade; no diploma
      # High school graduate or GED completed
      # Some college credit, but no degree
      # Associate degree (e.g., AA, AS)
      # Bachelor’s degree (e.g., BA, AB, BS)
      # Master’s degree (e.g., MA, MS, MEng, MEd, MSW, MBA)
      # Doctorate (e.g., PhD, EdD)
      # Professional degree (e.g., MD, DDS, DVM, LLB, JD)
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types
      t.string :decedents_education

      # 52. DECEDENT OF HISPANIC ORIGIN? Check the box that best describes whether the decedent is
      # Spanish/Hispanic/Latino. Check the “No” box if decedent is not Spanish/Hispanic/Latino.
      #
      # No, not Spanish/Hispanic/Latino
      # Yes, Mexican, Mexican American, Chicano
      # Yes, Puerto Rican
      # Yes, Cuban
      # Yes, other Spanish/Hispanic/Latino (Specify)
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types (allowing other)
      t.string :decedent_of_hispanic_origin, :decedent_of_hispanic_origin_specified

      # 53. DECEDENT’S RACE (Check one or more races to indicate what the decedent considered himself or
      # herself to be)
      #
      # White
      # Black or African American
      # American Indian or Alaska Native
      # Asian Indian (Name of the enrolled or principal tribe)
      # Chinese
      # Filipino
      # Japanese
      # Korean
      # Vietnamese
      # Other Asian (Specify)
      # Native Hawaiian
      # Guamanian or Chamorro
      # Samoan
      # Other Pacific Islander (Specify)
      # Other (Specify)
      # TODO: We need to enforce that this field is constrained to particular values, perhaps using postgres enumerated types (allowing various flavors of other)
      t.string :decedents_race, :decedents_race_specified

      # 54. DECEDENT’S USUAL OCCUPATION (Indicate type of work done during most of working life. DO NOT USE RETIRED)
      t.string :decedents_usual_occupation

      # 55. KIND OF BUSINESS/INDUSTRY
      t.string :decedents_kind_of_business_or_industry

      t.timestamps
    end
  end
end
