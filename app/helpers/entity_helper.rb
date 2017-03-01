# Entity helper module; used for structured data (funeral directors, etc.)
module EntityHelper
  def self.get_funeral_facility_names
    fd_names = []
    FuneralFacility.all.each do |fd|
      fd_names.push(fd.name)
    end
    fd_names
  end

  def self.get_funeral_facility_details(name)
    FuneralFacility.find_by name: name
  end
end
