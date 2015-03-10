# This migration comes from multitenacy (originally 20150301025920)
class CreateMultitenacyUsers < ActiveRecord::Migration
  def change
    create_table :multitenacy_users do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
