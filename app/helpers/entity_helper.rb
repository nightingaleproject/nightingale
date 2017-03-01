# Entity helper module; used for structured data (funeral directors, etc.)
module EntityHelper
  def self.get_funeral_director_names
    fd_names = []
    FuneralDirector.all.each do |fd|
      fd_names.push(fd.name)
    end
    fd_names
  end
  
  def self.get_funeral_director_details(name)
    FuneralDirector.find_by name: name
  end
end