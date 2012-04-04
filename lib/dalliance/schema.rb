module Dalliance
  module Schema
    def add_dalliance
      column :dalliance_error_hash, :text, {}
      column :dalliance_status, :string, {:null => false, :default => 'pending'}
    end
  end
end