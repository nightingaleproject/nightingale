# Death Record model
class DeathRecord < ApplicationRecord
  has_many :cause_of_death, -> { order(position: :asc) }
  accepts_nested_attributes_for :cause_of_death
  belongs_to :user

  cattr_accessor :form_steps do
    %w(identity demographics disposition medical)
  end

  attr_accessor :form_step, :ssn1, :ssn2, :ssn3

  # Identity fields required
  with_options if: -> { required_for_step?(:identity) } do |step|
    step.validates :first_name, presence: true
    step.validates :last_name, presence: true
    step.validates :social_security_number, presence: true
    step.validates :street, presence: true
    step.validates :city, presence: true
    step.validates :state, presence: true
    step.validates :county, presence: true
    step.validates :zip_code, presence: true
    step.validates :inside_city_limits, presence: true
    step.validates :father_first_name, presence: true
    step.validates :father_last_name, presence: true
    step.validates :mother_first_name, presence: true
    step.validates :mother_last_name, presence: true
  end

  # Demographics fields required
  with_options if: -> { required_for_step?(:demographics) } do |step|
    step.validates :sex, presence: true
    step.validates :date_of_birth, presence: true
    step.validates :birthplace_city, presence: true
    step.validates :birthplace_state, presence: true
    step.validates :birthplace_country, presence: true
    step.validates :ever_in_us_armed_forces, presence: true
    step.validates :marital_status_at_time_of_death, presence: true
    step.validates :education, presence: true
    step.validates :hispanic_origin, presence: true
    step.validates :race, presence: true
    step.validates :usual_occupation, presence: true
    step.validates :kind_of_business, presence: true
  end

  # Disposition fields required
  with_options if: -> { required_for_step?(:disposition) } do |step|
    # TODO
  end

  # Medical fields required
  with_options if: -> { required_for_step?(:medical) } do |step|
    # TODO
  end

  def required_for_step?(step)
    return true if form_step.nil?
    return true if self.form_steps.index(step.to_s) <= self.form_steps.index(form_step)
  end
end
