require 'sqlite3'

module Tact
  class Database
    attr_reader :db

    def initialize
      home_dir = File.expand_path("~")
      Dir.mkdir("#{home_dir}/.tact") unless File.exists?("#{home_dir}/.tact")
      @db = SQLite3::Database.new("#{File.expand_path("~")}/.tact/tact.sqlite3")
      @db.results_as_hash = true
      @db.execute("pragma foreign_keys = on")
      create_tables
    end

    def create_tables
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
      @db.execute(contact_table)
      @db.execute(phone_numbers_table)
      @db.execute(emails_table)
    end
  end
end