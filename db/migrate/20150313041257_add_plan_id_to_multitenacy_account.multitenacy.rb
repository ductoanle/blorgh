# This migration comes from multitenacy (originally 20150313040456)
class AddPlanIdToMultitenacyAccount < ActiveRecord::Migration
  def change
    add_column :multitenacy_accounts, :plan_id, :integer
  end
end
