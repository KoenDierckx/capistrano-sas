namespace :load do
  task :defaults do
    set :sas_systemd_roles, %w[all]
    set :sas_systemd_use_sudo, false
  end
end

namespace :systemd do
  %w[start stop restart enable disable].each do |command|
    desc "#{command.capitalize} service"
    task command do
      on roles(fetch(:sas_systemd_roles)) do |host|
        host.properties.systemd_units.each do |systemd_unit|
          sas_systemctl(:"#{command}", systemd_unit)
        end
      end
    end
  end

  desc 'Show the status of all services'
  task :status do
    on roles(fetch(:sas_systemd_roles)) do |host|
      host.properties.systemd_units.each do |systemd_unit|
        sas_systemctl(:status, systemd_unit)
      end
    end
  end

  desc 'Reload systemd manager configuration'
  task 'daemon-reload' do
    on roles(fetch(:sas_systemd_roles)) do
      sas_systemctl(:'daemon-reload')
    end
  end

  def sas_systemctl(*args)
    fetch(:sas_systemd_use_sudo) ? sudo(:systemctl, *args) : execute(:systemctl, *args)
  end
end

after 'deploy:published', 'systemd:daemon-reload'
after 'deploy:finished', 'systemd:restart'
