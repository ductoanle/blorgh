# This migration comes from multitenacy (originally 20150305125622)
class CreateMultitenacyMembers < ActiveRecord::Migration
  def change
    create_table :multitenacy_members do |t|
      t.integer :account_id
      t.integer :user_id

      t.timestamps
    end
  end
end
