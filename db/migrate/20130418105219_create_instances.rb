class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.integer :container_id
      t.string :ip
      t.string :assigned_port
      t.integer :instance_type
      t.string :unique_hash

      t.timestamps
    end
  end
end
