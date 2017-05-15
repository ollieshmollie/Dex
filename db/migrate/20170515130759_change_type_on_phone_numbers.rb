class ChangeTypeOnPhoneNumbers < ActiveRecord::Migration
  def change
    rename_column :phone_numbers, :type, :kind
  end
end
