# helper
module DeathRecordsHelper

  def new_death_record
    @death_record = DeathRecord.new
    @death_record.save
    return @death_record
  end

end
