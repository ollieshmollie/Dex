# require needed gems
require 'fileutils'
require 'active_record'
require 'sqlite3'
require 'colored'

# require lib files
require 'tact/authorizable'
require 'tact/card'
require 'tact/contact'
require 'tact/email'
require 'tact/google_client'
require 'tact/phone_number'
require 'tact/rolodex'
require 'tact/tact'
require 'tact/version'


APP_ROOT ||= File.join(File.dirname(__FILE__), '../')
DEV_DB ||= File.join(File.expand_path('~'), '.tact', 'tact.sqlite3')
TEST_DB ||= File.join(File.expand_path('~'), '.tact', 'tact_test.sqlite3')
MIGRATIONS_DIR ||= 'db/migrate'

# tells AR what db file to use
if ENV['GEM_ENV'] == 'test'
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => TEST_DB 
  )
else
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => DEV_DB 
  )
end

# Make tact directory
if !File.exists?("#{File.expand_path('~')}/.tact")
  FileUtils.mkdir("#{File.expand_path('~')}/.tact")
end

# Create database
SQLite3::Database.new(DEV_DB)
SQLite3::Database.new(TEST_DB)

# Run migrations
ActiveRecord::Migrator.migrations_paths << APP_ROOT + 'db/migrate'
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
