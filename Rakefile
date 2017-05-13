require "bundler/gem_tasks"
task :default => :spec

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r tact.rb"
end
