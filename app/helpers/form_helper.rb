# Form Helper module
module FormHelper
  def setup_death_record(death_record)
    while death_record.cause_of_death.size < 4
      death_record.cause_of_death << CauseOfDeath.new
    end
    death_record
  end
end
