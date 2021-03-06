require 'bundler/gem_tasks'
require 'fileutils'

task :environment do
  require 'tact'
end

namespace :generate do
  desc "Create an empty migration in db/migrate, e.g., rake generate:migration NAME=create_tasks"
  task :migration => :environment do
    unless ENV.has_key?('NAME')
      raise "Must specificy migration name, e.g., rake generate:migration NAME=create_tasks"
    end

    name     = ENV['NAME'].camelize
    filename = "%s_%s.rb" % [Time.now.strftime('%Y%m%d%H%M%S'), ENV['NAME'].underscore]
    path     = File.join('db', 'migrate', filename)

    if File.exist?(path)
      raise "ERROR: File '#{path}' already exists"
    end

    puts "Creating #{path}"
    File.open(path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{name} < ActiveRecord::Migration
          def change
          end
        end
      EOF
    end
  end
end

task :make_tact_dir do
  if !File.exists?("#{File.expand_path('~')}/.tact")
    FileUtils.mkdir("#{File.expand_path('~')}/.tact")
  end
end

namespace :db do
  desc "Create databases"
  task :create => [:environment, :make_tact_dir] do
    SQLite3::Database.new(DEV_DB)
    SQLite3::Database.new(TEST_DB)
  end

  desc "Drop databases"
  task :drop => :environment do
    FileUtils.rm DEV_DB
    FileUtils.rm TEST_DB
  end

  desc "Run migrations"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrations_paths << File.dirname(__FILE__) + 'db/migrate'
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
      ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
    end
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
  end

  desc "Retrieves the current schema version number"
  task :version do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end
end

desc "Run specs in test environment"
task :spec => :environment do
  sh 'rspec'
end

desc "Open console with this library required"
task :console do
  sh 'irb -I lib -r tact.rb'
end

desc "Uninstall local version of gem"
task :uninstall do
  sh 'yes | gem uninstall tact'  
  sh 'rm tact-*' unless Dir.glob('./tact-*').empty?
end

desc "Build and install local gem version"
task :build => :uninstall do
  sh 'gem build tact.gemspec && gem install tact'
end

