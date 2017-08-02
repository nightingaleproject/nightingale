'




'# VIEWS Helper module
module ViewsHelper
  require 'views/views'

  # Call VIEWS connector with death record info.
  def self.views_for_record(contents)
    # messages = Views.validate(cause_of_death_line1: contents['cod.immediate'], 
    #                           cause_of_death_duration1: contents['cod.immediateInt'],
    #                           cause_of_death_line2: contents['cod.under1'],
    #                           cause_of_death_duration2: contents['cod.under1Int'],
    #                           cause_of_death_line3: contents['cod.under2'],
    #                           cause_of_death_duration3: contents['cod.under2Int'],
    #                           cause_of_death_line4: contents['cod.under3'],
    #                           cause_of_death_duration4: contents['cod.under3Int'],
    #                           actual_or_presumed_date_of_death: ,
    #                           date_of_injury: ,
    #                           time_of_injury: ,
    #                           place_of_injury: ,
    #                           description_of_injury_occurrence: ,
    #                           transportation_injury_role: ,
    #                           sex: ,
    #                           date_of_birth: ,
    #                           did_tobacco_use_contribute_to_death: ,
    #                           was_an_autopsy_performed: ,
    #                           were_autopsy_findings_available: ,
    #                           manner_of_death: ,
    #                           injury_at_work: 
    #                           )
    # debugger
  end
end
