class AddUserNumberToInstance3 < ActiveRecord::Migration
  def change
    remove_column :instances, :user
    add_column :instances, :user, :string
  end
end
