# transfer.rb
# Converts existing contact data from JSON format to sqlite3 database.

require 'sqlite3'
require 'json'
require_relative 'lib/dex'

def create_tables(db)
  contact_table = <<~eof
      CREATE TABLE IF NOT EXISTS contacts(
        id integer primary key,
        first_name varchar(255) not null,
        last_name varchar(255) not null,
        constraint name_unique unique (first_name, last_name)
      );
      eof
    phone_numbers_table = <<~eof
      CREATE TABLE IF NOT EXISTS phone_numbers(
        id integer primary key,
        type varchar(255),
        number varchar(255),
        contact_id int,
        foreign key (contact_id) references contacts(id) on delete cascade
      );
      eof
    emails_table = <<~eof
      CREATE TABLE IF NOT EXISTS emails(
        id integer primary key,
        address varchar(255),
        contact_id,
        foreign key (contact_id) references contacts(id) on delete cascade
      );
      eof
    db.execute(contact_table)
    db.execute(phone_numbers_table)
    db.execute(emails_table)
end

def transfer_contacts(json_file, db)
  json = File.read(json_file)
  contacts = JSON.parse(json)

  id = 1
  contacts.each do |contact|
    contact_query = "INSERT INTO contacts (first_name, last_name)"\
                    "VALUES ('#{contact["first_name"]}', '#{contact["last_name"]}');"
    db.execute(contact_query)

    contact["phone_numbers"].each do |number|
      ph_number_query = "INSERT INTO phone_numbers (type, number, contact_id)"\
                        "VALUES ('#{number["type"]}', '#{number["number"]}', #{id});"
      db.execute(ph_number_query)
    end  

    contact["emails"].each do |email|
      email_query = "INSERT INTO emails (address, contact_id)"\
                    "VALUES ('#{email["address"]}', #{id});"
      db.execute(email_query)
    end
    id += 1
  end
end

db = SQLite3::Database.new("dex.sqlite3")
create_tables(db)

transfer_contacts('contacts.json', db)
