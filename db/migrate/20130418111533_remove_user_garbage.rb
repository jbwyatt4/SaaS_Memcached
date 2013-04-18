class RemoveUserGarbage < ActiveRecord::Migration
  def change
    remove_column :users, :memcached
    remove_column :users, :docker_ip
    remove_column :users, :secure_ip
    remove_column :users, :container_id
  end
end
