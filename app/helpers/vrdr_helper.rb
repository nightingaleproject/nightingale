# VRDR Helper module
module VrdrHelper
  def self.get_host
    return ENV['VRDR_URL'] || 'localhost:8080'
  end
end
