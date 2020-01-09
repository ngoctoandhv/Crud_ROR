class AddAccountActivationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :account_activation_sent_at, :datetime
  end
end
