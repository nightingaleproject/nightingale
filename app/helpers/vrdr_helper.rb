# VRDR Helper module
module VrdrHelper
  def self.get_host
    return ENV['VRDR_URL'] || 'http://localhost:8080'
  end
end
