# This migration comes from multitenacy (originally 20150310162058)
class CreateMultitenacyPlans < ActiveRecord::Migration
  def change
    create_table :multitenacy_plans do |t|
      t.string :name
      t.float :price
      t.string :braintree_id

      t.timestamps
    end
  end
end
