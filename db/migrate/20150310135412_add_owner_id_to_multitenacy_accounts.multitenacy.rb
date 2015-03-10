# This migration comes from multitenacy (originally 20150301025702)
class AddOwnerIdToMultitenacyAccounts < ActiveRecord::Migration
  def change
    add_column :multitenacy_accounts, :owner_id, :integer
  end
end
