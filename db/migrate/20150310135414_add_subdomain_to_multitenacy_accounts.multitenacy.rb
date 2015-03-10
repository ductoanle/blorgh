# This migration comes from multitenacy (originally 20150302160939)
class AddSubdomainToMultitenacyAccounts < ActiveRecord::Migration
  def change
    add_column :multitenacy_accounts, :subdomain, :string
    add_index :multitenacy_accounts, :subdomain
  end
end
