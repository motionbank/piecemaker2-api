require 'rubygems'
require 'bundler'
require 'yaml' 

BASE_PATH = File.dirname(File.absolute_path(__FILE__))

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
    spec.pattern = FileList['spec/api/*_spec.rb', 'spec/models/*_spec.rb',
      'spec/lib/*_spec.rb']
  end  

  desc "generate nice html view"
  task :html do
    system "rspec --format html --out docs/rspec.html"
  end
end



task :default do
  exec "rake -T"
end


desc "Start|Stop production API (as deamon)"
task :daemon, :action do |cmd, args|

  def pid_exist?(pid)
    begin
      return Process.getpgid(pid)
    rescue
      return false
    end
  end

  def check_pid_file
    if File.exist?("api.pid")
      # pid file exists: api running?
      pid = IO.read("api.pid").to_i

      if(pid_exist?(pid))
        puts "api server is running (PID: #{pid})"
        exit 0
      end

      # pid file exists, but process crashed maybe
      # anyway, delete pid file
      File.delete("api.pid")
    end
  end

  if args[:action] == "start"
    check_pid_file

    # no process is running ... start a new one
    system "rackup -E production -D -P api.pid > log/daemon_production.log"
    sleep 0.5
    check_pid_file

    # if you reached this, api was not started
    puts "api server not running"
    exit 50

  elsif args[:action] == "stop"
    if File.exist?("api.pid")
      pid = IO.read("api.pid").to_i
      if(pid_exist?(pid))
        system "kill $(cat api.pid)"
        File.delete("api.pid")
        exit 0
      end
    end
    exit 0
  elsif args[:action] == "status"
    check_pid_file

    # if you reached this, api was not started
    puts "api server not running"
    exit 50
  end
end


desc "Start API with environment (prod|dev)"
task :start, :env do |cmd, args|
  env = expand_env_string(args[:env]) || "production"
  if env == "production"
    puts "Starting in production mode ..."
    exec "rackup -E production"
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
  task :create_super_admin, :env, :username do |cmd, args|
    env = expand_env_string(args[:env]) || "development"
    Rake::Task['environment'].invoke(env)

    require "digest"
    api_access_key = Piecemaker::Helper::API_Access_Key::generate
    time_now = Time.now.to_i

    name = args[:username] || "Super Admin"
    email = args[:username] || "super-admin-#{time_now}@example.com"
    password = args[:username] || "super-admin-#{time_now}"

    DB[:users].insert(
      :name => name, 
      :email => email,
      :password => Digest::SHA1.hexdigest(password),
      :api_access_key => api_access_key,
      :user_role_id => 'super_admin')

    puts ""
    puts "Email    : #{email}"
    puts "Password : #{password}"
    puts "Role     : super_admin"
    puts ""
    puts "A fresh API Access Key has been generated '#{api_access_key}'."
  end

  desc "Run database migrations (:version is optional and defaults to latest)"
  task :migrate, :env, :version do |cmd, args|
    env = expand_env_string(args[:env]) || "development"
    Rake::Task['environment'].invoke(env)
 
    require 'sequel/extensions/migration'
    if(args[:version])
      Sequel::Migrator.apply(DB, "db/migrations", args[:version].to_i)
    else
      Sequel::Migrator.apply(DB, "db/migrations")
    end
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
      DB.drop_table(table, :cascade=>true)
    end
  end
 
  desc "Reset the database (nuke & migrate & import_from_file)"
  task :reset, :env do |cmd, args|
    env = expand_env_string(args[:env])
    Rake::Task['db:nuke'].invoke(env)
    Rake::Task['db:migrate'].invoke(env)
    Rake::Task['db:import_from_file'].invoke(env, 'user_roles')
    Rake::Task['db:import_from_file'].reenable # @todo use execute instead?
    Rake::Task['db:import_from_file'].invoke(env, 'role_permissions')
  end

  desc "Export table into file"
  task :export_into_file, :env, :table do |cmd, args|
    unless args[:table]
      puts "Usage: rake db:export_into_file[env,'table']"
      exit 1
    end
    env = expand_env_string(args[:env])
    Rake::Task['environment'].invoke(env)
    DB.copy_into( args[:table].to_sym , {
        :data => File.read( BASE_PATH + "/db/init/#{args[:table]}.sql" ),
        :format => :csv,
        :options => "HEADER TRUE"
      })
  end

  desc "Import table into database"
  task :import_from_file, :env, :table do |cmd, args|
    unless args[:table]
      puts "Usage: rake db:import_from_file[env,'table']"
      exit 1
    end
    env = expand_env_string(args[:env])
    Rake::Task['environment'].invoke(env)
    DB.copy_into( args[:table].to_sym , {
        :data => File.read( BASE_PATH + "/db/init/#{args[:table]}.sql" ),
        :format => :csv,
        :options => "HEADER TRUE"
      })
  end

end




def scan_entities(verbose)
  return_value = []

  entities = []
  Dir[BASE_PATH + "/api/*"].each do |file|
    line_no = 0
    line_stack = []
    IO.foreach(file) do |line|
      line_no += 1
      line_stack << line
      authorize = line.scan(/authorize! .*/)

      if authorize[0]

        desc = []
        url = []
        line_stack.reverse.each do |lstack|
          if desc.size == 0 || url.size == 0
            desc = lstack.scan(/desc "(.*)"/) if desc.size == 0
            url = lstack.scan(/((get|put|post|delete) .*)/) if url.size == 0
          else
            line_stack = []
          end
        end
        line_stack = []

        if verbose
          return_value << [
            "__#{authorize[0]}__",
            url[0][0].gsub(/do */, "") + " in api/#{File.basename(file)}:#{line_no}",
            desc,
            ""
          ]       
        else
          _action = authorize[0].scan(/:(.*), /).flatten[0]
          entities << _action if _action
        end
      end
    end
  end

  unless verbose
    entities.uniq!
    entities.sort!
    return entities
  else
    return return_value
  end
end

namespace :roles do

  desc "Scan files for permission entities"
  task :scan_entities, :verbose do |cmd, args|
    puts scan_entities(args[:verbose])
  end

  desc "Update config/permissions.yml with all available permissions"
  task :update_permissions_file do
    entities = scan_entities(false)
    content = "# this file is auto-generated with 'rake roles:update_permissions_file'" + "\n" + YAML.dump(entities)
    IO.write('config/permissions.yml', content)
    puts "config/permission.yml updated"
  end


  desc "Generate roles and permissions matrix from database (format:html|json)"
  task :output, :env, :format do |cmd, args|
    env = expand_env_string(args[:env]) || "development"
    Rake::Task['environment'].invoke(env)
    entities = scan_entities(false)

    # build user roles array
    def get_user_roles_ordered_by_inheritance(id, user_roles_ordered)
      root_user_roles = UserRole.where(:inherit_from_id => id).all
      if root_user_roles
        root_user_roles.each do |user_role|
          user_roles_ordered << user_role
          get_user_roles_ordered_by_inheritance(
            user_role.id, user_roles_ordered)
        end
      end
    end

    @user_roles_ordered = []
    get_user_roles_ordered_by_inheritance(nil, @user_roles_ordered)
    @user_roles_ordered.reverse!


    # build role permissions array
    @distinct_entities = RolePermission.distinct(:action).select(:action).order(:action).all

    # build matrix
    matrix = []
    @distinct_entities.each do |action|
      action = action.action
      
      permissions = {}

      @user_roles_ordered.each do |user_role|

        permission = Piecemaker::Helper::Auth::get_permission_recursively(user_role, action)
        if permission
          if permission.allowed
            permissions[user_role.id] = "Yes"
          else
            permissions[user_role.id] = "No"
          end
        else
          permissions[user_role.id] = "No"
        end
      end

      deleted_action = entities.delete(action)

      matrix << {
        :action => action + (deleted_action ? "" : " (not used)"),
        :permissions => permissions
      }

      
    end

    entities.each do |action|

      permissions = {}
      @user_roles_ordered.each do |user_role|
        permissions[user_role.id] = "Def"
      end

      matrix << {
        :action => action,
        :permissions => permissions
      }
    end

    output = {
      :headers => @user_roles_ordered.map{|user_role| user_role.id },
      :data => matrix
    }


    # all done ... do something with the data
    if args[:format] == "html"
      
      puts "<html>"
      puts "<head>"
      puts "<style type='text/css'>"
        puts IO.read(BASE_PATH + "/docs/roles_matrix.css")
      puts "</style>"
      puts "</head>"      
      puts "<body>"
        puts "<table>"
          # header
          puts "<thead>"
          puts "<tr>"
            puts "<th>Action</th>"
            output[:headers].each do |h|
              puts "<th>#{h}</th>"
            end
          puts "<tr>"
          puts "</thead>"

          # data
          puts "<tbody>"
          output[:data].each do |e|
            puts "<tr>"
              puts "<td class='action'><input type='checkbox'> #{e[:action]}</td>"
              output[:headers].each do |p|
                puts "<td class='permission #{e[:permissions][p]}'>#{e[:permissions][p]}</td>"
              end
            puts "</tr>"
          end
          puts "</tbody>"

        puts "</table>"
      puts "</body>"
      puts "</html>"

    else # json
      puts output
    end
      
  end

end

