# Greeting Helper module
module GreetingHelper
  # Generates a pretty greeting for a user
  # Example: 'Welcome, John Doe (Funeral Director)'
  def self.pretty_greeting(user)
    greeting = 'Welcome, '
    greeting += if !user.first_name.empty? && !user.last_name.empty?
                  user.first_name + ' ' + user.last_name
                else
                  user.email
                end
    unless user.roles.empty?
      user.roles.as_json.each do |role|
        greeting += if role == user.roles.as_json.first && role == user.roles.as_json.last
                      ' (' + role['name'].titleize + ')'
                    elsif role == user.roles.as_json.first
                      ' (' + role['name'].titleize + ', '
                    elsif role == user.roles.as_json.last
                      role['name'].titleize + ')'
                    else
                      role['name'].titleize
                    end
        if role != user.roles.as_json.first && role != user.roles.as_json.last
          greeting += ', '
        end
      end
    end
    greeting
  end
end
