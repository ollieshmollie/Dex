class CreateTables < ActiveRecord::Migration[4.2]
  def change
    create_table :contacts do |t|
      t.string :first_name, limit: 20
      t.string :last_name, limit: 20

      t.timestamps
    end
    create_table :phone_numbers do |t|
      t.string :number, limit: 15
      t.string :type, limit: 10
    end
    create_table :emails do |t|
      t.string :address, limit: 50
    end
  end
end
