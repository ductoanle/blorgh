# This migration comes from multitenacy (originally 20150314100438)
class AddBraintreeSubscriptionIdToMultitenacyAccount < ActiveRecord::Migration
  def change
    add_column :multitenacy_accounts, :braintree_subscription_id, :string
  end
end
