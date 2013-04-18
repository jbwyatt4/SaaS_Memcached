class AddUserNumberToInstance2 < ActiveRecord::Migration
  def change
    add_column :instances, :user, :integer
  end
end
