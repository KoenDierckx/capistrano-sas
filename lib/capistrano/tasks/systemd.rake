namespace :load do
  task :defaults do
    set :systemd_use_sudo, false
    set :systemd_roles, %w[all]
  end
end

namespace :systemd do
  %w[start stop restart enable disable].each do |command|
    desc "#{command.capitalize} service"
    task command do
      loop_roles_and_units do |_host, systemd_unit|
        systemctl(:"#{command}", systemd_unit)
      end
    end
  end

  desc 'Show the status of all services'
  task :status do
    loop_roles_and_units do |_host, systemd_unit|
      systemctl(:status, systemd_unit)
    end
  end

  desc 'Reload systemd manager configuration'
  task 'daemon-reload' do
    on roles(fetch(:systemd_roles)) do
      systemctl(:'daemon-reload')
    end
  end

  def loop_roles_and_units
    on roles(fetch(:systemd_roles)) do |host|
      on host.properties.systemd_units do |systemd_unit|
        yield(host, systemd_unit)
      end
    end
  end

  def systemctl(*args)
    fetch(:systemd_use_sudo) ? sudo(:systemctl, *args) : execute(:systemctl, *args)
  end
end

after 'deploy:published', 'systemd:daemon-reload'
after 'deploy:finished', 'systemd:restart'

