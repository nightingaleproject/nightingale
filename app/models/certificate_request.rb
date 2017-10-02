class CertificateRequest < ApplicationRecord
  audited
  belongs_to :creator, class_name: 'User'
  belongs_to :death_certificate
end
