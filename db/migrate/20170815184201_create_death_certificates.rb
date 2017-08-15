class CreateDeathCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :death_certificates do |t|
      t.binary :document
      t.json :metadata, default: {}
      t.belongs_to :death_record
      t.belongs_to :creator, class_name: 'User'
      t.timestamps
    end
  end
end
