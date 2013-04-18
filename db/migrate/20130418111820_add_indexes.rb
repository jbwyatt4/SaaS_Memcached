class AddIndexes < ActiveRecord::Migration
  def change
    add_index :instances, :ip
    add_index :instances, :container_id
    add_index :instances, :assigned_port
    add_index :instances, :unique_hash
    add_index :instances, :user
  end
end
