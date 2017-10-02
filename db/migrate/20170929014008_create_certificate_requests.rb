class CreateCertificateRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :certificate_requests do |t|
      t.belongs_to :death_certificate
      t.belongs_to :creator, class_name: 'User'
      t.timestamps
    end
  end
end
