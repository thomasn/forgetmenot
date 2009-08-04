# Deployment recipe for forgetmenot on Passenger
# Thanks: http://www.zorched.net/2008/06/17/capistrano-deploy-with-git-and-passenger/

set :application, "forgetmenot"
set :repository, "git://github.com/thomasn/forgetmenot.git"
set :deploy_to, "/var/www/rails/forgetmenot"
set :rails_env, "production"
set :branch, "master"    # FIXME yuk yuk yuk
set :user, "root"
set :runner, user
set :scm, :git
# set :scm_password, Proc.new { Capistrano::CLI.password_prompt("Git password for #{repository}: ") }
set :deploy_via, :remote_cache


# Use staging settings by default - override these in farm-specific tasks.
set :domain, ENV["TARGET_DOMAIN"]  ||  Proc.new { Capistrano::CLI.password_prompt("Target domain: ") }
role :web, domain
role :app, domain
role :db,  domain, :primary => true



# Invoke as: `cap aws deploy:cold` etc
task :aws do

  roles[:web].clear
  roles[:app].clear
  roles[:db].clear
  set :awsbox, "aws.example.com"
  role :web, awsbox
  role :app, awsbox
  role :db,  awsbox, :primary => true

end

# == BOILERPLATE == #



namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

[:start, :stop].each do |t|
  desc "#{t} task is a no-op with mod_rails"
  task t, :roles => :app do ; end
end

# We do not need script/spin :
deploy.task :start do
     # nothing
   end


desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  run "touch #{current_path}/tmp/restart.txt"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end


desc "Live deployment config after cap:deploy."
task :after_update_code, :roles => [:app] do
  run "ln -nsf #{release_path}/config/database.yml.#{application} #{release_path}/config/database.yml"
  run "chmod -R g+w #{release_path}/public/*"
  # sass needs to write to public/stylesheets and g+w is insufficient!??!! :
  run "chmod -R o+w #{release_path}/public/stylesheets"
  run "chmod -R g+w #{release_path}/tmp/*"
  # set setgid bit - files created within this dir will have group of parent dir (i.e. apache/mongrel), not of process:
  # log files are sensitive - make certain they are invisible to 'other' and have SETGID set on directories:
  # FIXME: Passenger refuses to start unless shared/log is o+x and *.log is o+rw...
  run "touch #{shared_path}/log/development.log"
  run "touch #{shared_path}/log/production.log"
  run "ln -s #{release_path}/.git/refs/heads/deploy #{release_path}/public/version"
  run "chmod 2777 #{release_path}/log"
  run "chmod 2777 #{shared_path}/log"
  run "chmod 0666 #{shared_path}/log/*"
  run "chown -R apache:apache #{release_path}"
  run "chown -R apache:apache #{shared_path}"

end
