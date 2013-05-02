class Instance < ActiveRecord::Base
  belongs_to :user
  attr_accessible :assigned_port, :container_id, :instance_type,
      :ip, :unique_hash, :user
  validates :assigned_port, presence: true, uniqueness: true
  validates :instance_type, presence: true
  #validates :user, presence: true
end
