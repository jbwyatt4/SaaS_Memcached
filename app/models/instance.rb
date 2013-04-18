class Instance < ActiveRecord::Base
  attr_accessible :assigned_port, :container_id, :instance_type, :ip, :unique_hash
end
