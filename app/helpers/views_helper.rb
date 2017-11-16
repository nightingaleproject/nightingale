# VIEWS Helper module
module ViewsHelper
  require 'views/views'

  # Call VIEWS connector with death record info.
  def self.views_for_record_cod(contents)
    messages = Views.validate(cause_of_death_line1: contents['immediate'],
                              cause_of_death_duration1: contents['immediateInt'],
                              cause_of_death_line2: contents['under1'],
                              cause_of_death_duration2: contents['under1Int'],
                              cause_of_death_line3: contents['under2'],
                              cause_of_death_duration3: contents['under2Int'],
                              cause_of_death_line4: contents['under3'],
                              cause_of_death_duration4: contents['under3Int'])
  end
end
