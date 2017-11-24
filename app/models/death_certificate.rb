class DeathCertificate < ApplicationRecord
  audited except: :document
  belongs_to :creator, class_name: 'User'
  belongs_to :death_record
end
