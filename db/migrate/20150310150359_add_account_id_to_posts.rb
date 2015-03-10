class AddAccountIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :account_id, :integer
    add_index :posts, :account_id
  end
end
