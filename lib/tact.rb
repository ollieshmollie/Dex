# require needed gems
require 'active_record'
require 'sqlite3'
require 'colored'

# recursively requires all files in ./lib and down that end in .rb
Dir['./lib/tact/*.rb'].each do |file|
  require file
end

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

require 'tact'
