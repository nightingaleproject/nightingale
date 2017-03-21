# Name Helper module
module NameHelper
  # Given a death record, return a pretty decedent name
  def self.pretty_decedent_name(death_record)
    NameHelper.pretty_name(death_record.first_name, death_record.middle_name, death_record.last_name)
  end

  # Returns a pretty printed name for a user
  def self.pretty_user_name(user_id)
    user = User.find(user_id)
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

  # Returns the email of the given user id
  def self.pretty_email(user_id)
    user = User.find(user_id)
    user.email
  end
end
