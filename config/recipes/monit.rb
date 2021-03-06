namespace :monit do
  desc "Setup all Monit configuration"
  task :setup do
    monit_config "monitrc", "/etc/monit/monitrc"
    nginx
    application == 'rusrails_v32' ? mysql : postgresql
    unicorn
    syntax
    force_reload
  end
  after "deploy:setup", "monit:setup"

  task(:nginx, roles: :web) { monit_config "nginx" }
  task(:mysql, roles: :db) { monit_config "mysql" }
  task(:postgresql, roles: :db) { monit_config "postgresql" }
  task(:unicorn, roles: :app) { monit_config "unicorn", "/etc/monit/conf.d/unicorn_#{application}.conf" }

  %w[start stop restart syntax force_reload].each do |command|
    desc "Run Monit #{command} script"
    task command do
      run "#{sudo} /etc/init.d/monit #{command.gsub(/_/, '-')}"
    end
  end
end

def monit_config(name, destination = nil)
  destination ||= "/etc/monit/conf.d/#{name}.conf"
  template "monit/#{name}.erb", "/tmp/monit_#{name}"
  run "#{sudo} mv /tmp/monit_#{name} #{destination}"
  run "#{sudo} chown root #{destination}"
  run "#{sudo} chmod 600 #{destination}"
end
