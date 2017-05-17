class ChangeTypeOnPhoneNumbers < ActiveRecord::Migration[4.2]
  def change
    rename_column :phone_numbers, :type, :kind
  end
end
