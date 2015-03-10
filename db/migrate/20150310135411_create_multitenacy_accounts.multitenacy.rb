# This migration comes from multitenacy (originally 20150228152315)
class CreateMultitenacyAccounts < ActiveRecord::Migration
  def change
    create_table :multitenacy_accounts do |t|
      t.string :name

      t.timestamps
    end
  end
end
