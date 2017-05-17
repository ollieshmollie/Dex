class AddForeignKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :phone_numbers, :contact_id, :integer
    add_column :emails, :contact_id, :integer
  end
end
