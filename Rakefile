require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require "sequel"

def expand_env_string(env)
  return "development" if env == "dev"
  return "production" if env == "prod"
  return env
end

namespace :spec do

  desc "watch files and run tests automatically"
  task :onchange do 
    system "guard -g specs"
  end

  desc "run tests now"
  RSpec::Core::RakeTask.new(:now) do |spec|
    # do not run integration tests, doesn't work on TravisCI
    spec.pattern = FileList['spec/api/*_spec.rb', 'spec/models/*_spec.rb']
  end  

  desc "generate nice html view"
  task :html do
    system "rspec --format html --out rspec.html"
  end
end



task :default do
  exec "rake -T"
end


desc "Start|Stop production API (as deamon)"
task :daemon, :action do |cmd, args|
  if args[:action] == "start"
    puts "Starting API ..."
    exec "RACK_ENV=production && nohup rackup 0<&- &>" +
          "log/production_daemon.log & " +
          "\necho $! > api.pid; exit 0"
  elsif args[:action] == "stop"
    puts "Stopping API ..."
    exec "kill $(cat api.pid); rm api.pid"
  end
end


desc "Start API with environment (prod|dev)"
task :start, :env do |cmd, args|
  env = expand_env_string(args[:env]) || "production"
  if env == "production"
    puts "Starting in production mode ..."
    exec "RACK_ENV=production rackup"
  elsif env == "development"
    puts "Starting in development mode ..."
    exec "bundle exec guard -g development"
  else
    puts "Please specify environment."
  end
    
end


task :environment, [:env] do |cmd, args|
  ENV["RACK_ENV"] = expand_env_string(args[:env]) || "development"
  require "./config/environment"
end

namespace :db do
  desc "Create super admin"
  task :create_super_admin, :env do |cmd, args|
    env = expand_env_string(args[:env]) || "development"
    Rake::Task['environment'].invoke(env)

    require "Digest"
    api_access_key = Piecemaker::Helper::API_Access_Key::generate
    time_now = Time.now.to_i
    DB[:users].insert(
      :name => "Super Admin", 
      :email => "super-admin-#{time_now}@example.com",
      :password => Digest::SHA1.hexdigest("super-admin-#{time_now}"),
      :api_access_key => api_access_key,
      :is_admin => true)

    puts ""
    puts "Email   : super-admin-#{time_now}@example.com"
    puts "Password: super-admin-#{time_now}"
    puts ""
    puts "A fresh API Access Key has been generated '#{api_access_key}'."
    puts "Please note that this key will change the next time this user logs in."
  end

  desc "Run database migrations"
  task :migrate, :env do |cmd, args|
    env = expand_env_string(args[:env]) || "development"
    Rake::Task['environment'].invoke(env)
 
    require 'sequel/extensions/migration'
    Sequel::Migrator.apply(DB, "db/migrations")
  end
 
  desc "Rollback the database"
  task :rollback, :env do |cmd, args|
    env = expand_env_string(args[:env]) || "development"
    Rake::Task['environment'].invoke(env)
 
    require 'sequel/extensions/migration'
    version = (row = DB[:schema_info].first) ? row[:version] : nil
    Sequel::Migrator.apply(DB, "db/migrations", version - 1)
  end
 
  desc "Nuke the database (drop all tables)"
  task :nuke, :env do |cmd, args|
    env = expand_env_string(args[:env]) || "development"
    Rake::Task['environment'].invoke(env)
    DB.tables.each do |table|
      # @todo: CASCADE equivalent command for DB.drop_table?
      # DB.drop_table(table)
      # DB[table.to_sym].drop(:cascade => true)
      DB.run("DROP TABLE #{table} CASCADE")
    end
  end
 
  desc "Reset the database (nuke & migrate)"
  task :reset, :env do |cmd, args|
    env = expand_env_string(args[:env])
    Rake::Task['db:nuke'].invoke(env)
    Rake::Task['db:migrate'].invoke(env)
  end
end

