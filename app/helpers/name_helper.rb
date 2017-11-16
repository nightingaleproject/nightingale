# Name Helper module
module NameHelper
  # Returns a pretty printed name for a User
  def self.pretty_user_name(user)
    NameHelper.pretty_name(user.first_name, nil, user.last_name)
  end

  # Given a first name, last name, and middle name (all optional),
  # return a pretty printed name.
  def self.pretty_name(first, middle, last)
    name = ''
    if !first.blank? && !last.blank?
      name += last.humanize + ', ' + first.humanize
    elsif !last.blank?
      name += last.humanize
    elsif !first.blank?
      name += first.humanize
    end
    unless middle.blank?
      name += ' ' + middle.humanize.first + '.'
    end
    name
  end
end
